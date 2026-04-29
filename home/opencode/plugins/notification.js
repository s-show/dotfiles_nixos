export const NotificationPlugin = async ({ project, client, $, directory, worktree }) => {
  return {
    event: async ({ event }) => {
      // Send notification on session completion
      if (event.type === "session.idle" || event.type === "permission.asked") {
        await $`notify --appId "OpenCode Notification" --category "OpenCode" --expire-time 5 "OpenCode notification." `
      }
    },
  }
}
