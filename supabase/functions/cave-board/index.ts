import { createClient } from "jsr:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": Deno.env.get("CAVE_ALLOWED_ORIGIN") ?? "https://kratos561.github.io",
  "Access-Control-Allow-Headers": "content-type, x-cave-access",
  "Access-Control-Allow-Methods": "GET, POST, PATCH, DELETE, OPTIONS",
  "Vary": "Origin",
};

const encoder = new TextEncoder();
const statuses = new Set(["pendiente", "proceso", "listo"]);
const priorities = new Set(["normal", "alta", "urgente"]);

function response(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });
}

function equal(a: Uint8Array, b: Uint8Array) {
  if (a.length !== b.length) return false;
  let result = 0;
  for (let i = 0; i < a.length; i += 1) result |= a[i] ^ b[i];
  return result === 0;
}

function hexBytes(hex: string) {
  if (!/^[a-f0-9]{64}$/i.test(hex)) return null;
  return Uint8Array.from(hex.match(/.{2}/g)!.map((value) => Number.parseInt(value, 16)));
}

async function hasAccess(request: Request) {
  const supplied = request.headers.get("x-cave-access") ?? "";
  const expected = hexBytes(Deno.env.get("CAVE_ACCESS_SECRET_SHA256") ?? "");
  if (!supplied || !expected) return false;
  const digest = new Uint8Array(await crypto.subtle.digest("SHA-256", encoder.encode(supplied)));
  return equal(digest, expected);
}

function string(value: unknown, max = 4000) {
  return typeof value === "string" ? value.trim().slice(0, max) : "";
}

function taskPayload(value: Record<string, unknown>, partial = false) {
  const next: Record<string, unknown> = {};
  if (!partial || "text" in value) {
    const text = string(value.text, 220);
    if (!text) throw new Error("El nombre del proyecto es obligatorio.");
    next.text = text;
  }
  for (const [key, max] of [["client", 220], ["description", 5000], ["phone", 80]] as const) {
    if (!partial || key in value) next[key] = string(value[key], max) || null;
  }
  if (!partial || "date" in value) {
    const date = string(value.date, 10);
    if (date && !/^\d{4}-\d{2}-\d{2}$/.test(date)) throw new Error("Fecha inválida.");
    next.date = date || null;
  }
  if (!partial || "payment_amount" in value) {
    const amount = Number(value.payment_amount ?? 0);
    if (!Number.isFinite(amount) || amount < 0 || amount > 100000000) throw new Error("Abono inválido.");
    next.payment_amount = amount;
  }
  if (!partial || "status" in value) {
    const status = string(value.status, 24) || "pendiente";
    if (!statuses.has(status)) throw new Error("Estado inválido.");
    next.status = status;
  }
  if (!partial || "priority" in value) {
    const priority = string(value.priority, 24) || "normal";
    if (!priorities.has(priority)) throw new Error("Prioridad inválida.");
    next.priority = priority;
  }
  if (!partial || "deleted_at" in value) {
    const deletedAt = value.deleted_at;
    if (deletedAt !== null && deletedAt !== undefined && (!Number.isInteger(deletedAt) || Number(deletedAt) < 0)) throw new Error("Archivo inválido.");
    next.deleted_at = deletedAt ?? null;
  }
  return next;
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: cors });
  const origin = request.headers.get("origin");
  if (origin && origin !== cors["Access-Control-Allow-Origin"]) return response({ error: "Origen no permitido." }, 403);
  if (!await hasAccess(request)) return response({ error: "Acceso no autorizado." }, 401);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRole = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceRole) return response({ error: "Servicio no configurado." }, 500);
  const database = createClient(supabaseUrl, serviceRole, { auth: { persistSession: false } });

  try {
    if (request.method === "GET") {
      const { data, error } = await database.from("tasks").select("*").order("updated_at", { ascending: false });
      if (error) throw error;
      return response({ data });
    }

    const body = await request.json();
    const operation = body?.operation;
    if (operation === "insert") {
      const supplied = body.task ?? {};
      const id = string(supplied.id, 100);
      if (!id) throw new Error("Identificador inválido.");
      const task = { id, ...taskPayload(supplied), created_at: Date.now(), updated_at: Date.now() };
      const { data, error } = await database.from("tasks").insert(task).select().single();
      if (error) throw error;
      return response({ data }, 201);
    }
    if (operation === "update") {
      const id = string(body.id, 100);
      if (!id) throw new Error("Identificador inválido.");
      const patch = { ...taskPayload(body.task ?? {}, true), updated_at: Date.now() };
      const { data, error } = await database.from("tasks").update(patch).eq("id", id).select().single();
      if (error) throw error;
      return response({ data });
    }
    if (operation === "delete") {
      const id = string(body.id, 100);
      if (!id) throw new Error("Identificador inválido.");
      const { data, error } = await database.from("tasks").delete().eq("id", id).select("id").maybeSingle();
      if (error) throw error;
      if (!data) throw new Error("El proyecto ya no existe.");
      return response({ ok: true });
    }
    return response({ error: "Operación no permitida." }, 400);
  } catch (error) {
    const message = error instanceof Error ? error.message : "No se pudo completar la solicitud.";
    return response({ error: message }, 400);
  }
});
