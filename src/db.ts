import { PrismaNeon } from "@prisma/adapter-neon"
import { PrismaClient } from "@prisma/client"

declare global {
  // eslint-disable-next-line no-var
  var cachedPrisma: PrismaClient
}

let prisma: PrismaClient
if (process.env.NODE_ENV === "production") {
  const connectionString = `${process.env.DATABASE_URL}`
  const adapter = new PrismaNeon({ connectionString })
  prisma = new PrismaClient({ adapter })
} else {
  if (!global.cachedPrisma) {
    const connectionString = `${process.env.DATABASE_URL}`
    const adapter = new PrismaNeon({ connectionString })
    global.cachedPrisma = new PrismaClient({ adapter })
  }
  prisma = global.cachedPrisma
}

export const db = prisma
