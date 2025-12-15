"use client";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://10.10.0.13:{{BACKEND_PORT}}";

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <div className="text-center">
        <h1 className="text-4xl font-bold mb-4">{"{{PROJECT_NAME}}"}</h1>
        <p className="text-muted-foreground mb-8">
          Full-stack application built with Next.js and FastAPI
        </p>
        
        <div className="flex gap-4 justify-center mb-8">
          <a
            href={`${API_URL}/health`}
            target="_blank"
            rel="noopener noreferrer"
            className="px-4 py-2 bg-primary text-primary-foreground rounded-md hover:opacity-90"
          >
            API Health
          </a>
          <a
            href={`${API_URL}/docs`}
            target="_blank"
            rel="noopener noreferrer"
            className="px-4 py-2 bg-secondary text-secondary-foreground rounded-md hover:opacity-90"
          >
            API Docs
          </a>
          <a
            href="/login"
            className="px-4 py-2 bg-secondary text-secondary-foreground rounded-md hover:opacity-90"
          >
            Login
          </a>
        </div>

        <div className="text-sm text-muted-foreground space-y-1">
          <p>Frontend: <code className="bg-muted px-1 rounded">http://10.10.0.13:{{FRONTEND_PORT}}</code></p>
          <p>Backend API: <code className="bg-muted px-1 rounded">{API_URL}</code></p>
        </div>
      </div>
    </main>
  );
}
