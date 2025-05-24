"use client"

import { SignIn } from "@clerk/nextjs"
import { useSearchParams } from "next/navigation"

const Page = () => {
  const searchParams = useSearchParams()

  return (
    <div className="w-full flex-1 flex items-center justify-center">
      <SignIn
        fallbackRedirectUrl="/welcome" forceRedirectUrl="/welcome"
      />
    </div>
  )
}

export default Page
