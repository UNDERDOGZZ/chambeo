import { serve } from "https://deno.land/std@0.202.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type AcceptOfferInput = {
  job_id: string;
  offer_id: string;
};

type JsonResponse = {
  job: Record<string, unknown> | null;
  assignment: Record<string, unknown> | null;
  accepted_offer: Record<string, unknown> | null;
};

const supabaseUrl = Deno.env.get("SUPABASE_URL");
const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

if (!supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey) {
  throw new Error("Missing Supabase environment variables.");
}

const serviceClient = createClient(supabaseUrl, supabaseServiceRoleKey);

const jsonResponse = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
    },
  });

serve(async (req) => {
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return jsonResponse({ error: "Missing Authorization header" }, 401);
  }

  let payload: AcceptOfferInput;
  try {
    payload = await req.json();
  } catch (_) {
    return jsonResponse({ error: "Invalid JSON payload" }, 400);
  }

  if (!payload.job_id || !payload.offer_id) {
    return jsonResponse({ error: "job_id and offer_id are required" }, 400);
  }

  const authClient = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userData, error: userError } = await authClient.auth.getUser();
  if (userError || !userData.user) {
    return jsonResponse({ error: "Unauthorized" }, 401);
  }

  const userId = userData.user.id;

  const { data: job, error: jobError } = await serviceClient
    .from("jobs")
    .select("*")
    .eq("id", payload.job_id)
    .maybeSingle();

  if (jobError || !job) {
    return jsonResponse({ error: "Job not found" }, 404);
  }

  if (job.client_id !== userId) {
    return jsonResponse({ error: "Forbidden" }, 403);
  }

  if (job.status !== "open") {
    return jsonResponse({ error: "Job is not open" }, 409);
  }

  const { data: offer, error: offerError } = await serviceClient
    .from("job_offers")
    .select("*")
    .eq("id", payload.offer_id)
    .eq("job_id", payload.job_id)
    .maybeSingle();

  if (offerError || !offer) {
    return jsonResponse({ error: "Offer not found" }, 404);
  }

  if (offer.status !== "pending") {
    return jsonResponse({ error: "Offer is not pending" }, 409);
  }

  const { data: acceptedOffer, error: acceptedOfferError } = await serviceClient
    .from("job_offers")
    .update({ status: "accepted" })
    .eq("id", offer.id)
    .select("*")
    .maybeSingle();

  if (acceptedOfferError || !acceptedOffer) {
    return jsonResponse({ error: "Failed to accept offer" }, 500);
  }

  const { data: assignment, error: assignmentError } = await serviceClient
    .from("job_assignments")
    .upsert(
      {
        job_id: job.id,
        client_id: job.client_id,
        worker_id: offer.worker_id,
      },
      { onConflict: "job_id" },
    )
    .select("*")
    .maybeSingle();

  if (assignmentError || !assignment) {
    return jsonResponse({ error: "Failed to create assignment" }, 500);
  }

  const { data: updatedJob, error: updatedJobError } = await serviceClient
    .from("jobs")
    .update({ status: "assigned" })
    .eq("id", job.id)
    .select("*")
    .maybeSingle();

  if (updatedJobError || !updatedJob) {
    return jsonResponse({ error: "Failed to update job" }, 500);
  }

  const { error: rejectError } = await serviceClient
    .from("job_offers")
    .update({ status: "rejected" })
    .eq("job_id", job.id)
    .neq("id", offer.id)
    .in("status", ["pending"]);

  if (rejectError) {
    return jsonResponse({ error: "Failed to reject other offers" }, 500);
  }

  const response: JsonResponse = {
    job: updatedJob,
    assignment,
    accepted_offer: acceptedOffer,
  };

  return jsonResponse(response);
});
