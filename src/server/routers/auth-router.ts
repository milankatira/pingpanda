import { db } from "@/db"
import { currentUser } from "@clerk/nextjs/server"
import { router } from "../__internals/router"
import { publicProcedure } from "../procedures"

export const dynamic = "force-dynamic"

export const authRouter = router({
  getDatabaseSyncStatus: publicProcedure.query(async ({ c, ctx }) => {
    try {
      const auth = await currentUser()

      if (!auth) {
        return c.json({ isSynced: false, error: "User not authenticated" })
      }

      const user = await db.user.findFirst({
        where: { externalId: auth.id },
      })

      if (!user) {
        try {
          await db.user.create({
            data: {
              quotaLimit: 100,
              externalId: auth.id,
              email: auth.emailAddresses[0].emailAddress,
            },
          })
        } catch (dbError) {
          console.error("Failed to create user:", dbError)
          return c.json({
            isSynced: false,
            error: "Failed to create user record",
          })
        }
      }

      return c.json({ isSynced: true })
    } catch (error) {
      console.error("Database sync error:", error)
      return c.json({
        isSynced: false,
        error: "Failed to sync with database",
      })
    }
  }),
})
