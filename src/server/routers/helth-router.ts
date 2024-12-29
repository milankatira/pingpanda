import { router } from "../__internals/router"
import { publicProcedure } from "../procedures"

export const healthRouter = router({
  healthCheck: publicProcedure.query(({ c }) => {
    return c.json({
      status: "OK",
      message: "Service is running smoothly.",
      timestamp: new Date().toISOString(),
    })
  }),
})
