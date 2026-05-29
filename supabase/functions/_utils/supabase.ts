import { createClient } from "npm:@supabase/supabase-js@2.49.4";

export const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
);

export const getUser = async (
    token: string,
) => (await supabaseClient.auth.getUser(token));
