export const SecurityPlugin: Plugin = async ({ client }) => {
  const sensitivePatterns = ['.env', 'secret', 'credentials', 'private-key']
  return {
    tool: {
      execute: {
        before: async (input, output) => {
          if (input.tool === "read" || input.tool === "bash") {
            const filePath = output.args.filePath.toLowerCase()
            if (sensitivePatterns.some(pattern => filePath.includes(pattern))) {
              throw new Error(`🚫 Blocked: Cannot read sensitive file ${output.args.filePath}`)
            }
          }
        }
      }
    }
  }
}
