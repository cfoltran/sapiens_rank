import { supabaseClient } from "../_utils/supabase.ts";
import { JWT } from "npm:google-auth-library@9";
import serviceAccount from "./service-account.json" with { type: "json" };

interface Notification {
  id: string;
  user_ids: string[];
  body: string;
  link?: string;
}

interface WebhookPayload {
  type: "INSERT";
  table: string;
  record: Notification;
  schema: "public";
}

const getAccessToken = ({
  clientEmail,
  privateKey,
}: {
  clientEmail: string;
  privateKey: string;
}): Promise<string> => {
  const jwtClient = new JWT({
    email: clientEmail,
    key: privateKey,
    scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
  });
  return new Promise((resolve, reject) => {
    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(new Error(`Failed to fetch access token: ${err.message}`));
        return;
      }
      resolve(tokens!.access_token!);
    });
  });
};

const sendNotification = async (
  fcmToken: string,
  title: string,
  body: string,
  link?: string,
) => {
  const accessToken = await getAccessToken({
    clientEmail: serviceAccount.client_email,
    privateKey: serviceAccount.private_key,
  });

  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token: fcmToken,
          notification: {
            title,
            body,
          },
          data: link ? { link } : undefined,
        },
      }),
    },
  );

  if (!response.ok) {
    const errorData = await response.json();
    throw new Error(
      `Failed to send notification. Status: ${response.status}, Error: ${JSON.stringify(errorData)
      }`,
    );
  }
  return await response.json();
};

Deno.serve(async (req) => {
  try {
    const payload: WebhookPayload = await req.json();
    const userIds = payload.record.user_ids;
    let profiles;

    if (userIds.length === 0) {
      const { data, error } = await supabaseClient
        .from("device_tokens")
        .select("fcm_token");

      if (error) {
        throw new Error(`Error fetching all device tokens: ${error.message}`);
      }
      profiles = data;
    } else {
      const { data, error } = await supabaseClient
        .from("device_tokens")
        .select("fcm_token")
        .in("user_id", userIds);

      if (error) {
        throw new Error(`Error fetching device tokens: ${error.message}`);
      }
      profiles = data;
    }

    if (!profiles || profiles.length === 0) {
      console.log(
        `No profiles with FCM tokens found for user_ids: ${userIds.length > 0 ? userIds.join(", ") : "all users"}`,
      );
      return new Response(
        JSON.stringify({ success: 0, failures: 0, message: "No valid FCM tokens found" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    const notificationPromises = profiles.map((profile) =>
      sendNotification(
        profile.fcm_token,
        "SapiensRank",
        payload.record.body,
        payload.record.link,
      )
    );

    const results = await Promise.allSettled(notificationPromises);

    const failedNotifications = results.filter(
      (result) => result.status === "rejected",
    );

    if (failedNotifications.length > 0) {
      console.error(
        `Failed to send ${failedNotifications.length} notifications.`,
        failedNotifications,
      );
    }

    return new Response(
      JSON.stringify({
        success: results.filter((r) => r.status === "fulfilled").length,
        failures: failedNotifications.length,
      }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("Error processing request:", err);
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : String(err) }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});
