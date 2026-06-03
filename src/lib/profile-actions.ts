"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export interface UpdateUsernameResult {
  ok: boolean;
  error?: string;
  full_name?: string;
}

export async function updateUsername(formData: FormData): Promise<UpdateUsernameResult> {
  const raw = (formData.get("full_name") as string | null) ?? "";
  const fullName = raw.trim();

  if (!fullName) {
    return { ok: false, error: "Display name cannot be empty." };
  }
  if (fullName.length > 80) {
    return { ok: false, error: "Display name must be 80 characters or fewer." };
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: "Not signed in." };

  const { error } = await supabase.auth.updateUser({
    data: { ...user.user_metadata, full_name: fullName },
  });
  if (error) return { ok: false, error: error.message };

  revalidatePath("/profile");
  return { ok: true, full_name: fullName };
}

export async function signOut() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect("/");
}
