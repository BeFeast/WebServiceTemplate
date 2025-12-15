export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <div className="text-center">
        <h1 className="text-4xl font-bold mb-4">{"{{PROJECT_NAME}}"}</h1>
        <p className="text-muted-foreground mb-8">
          Full-stack application built with Next.js and FastAPI
        </p>
        <div className="flex gap-4 justify-center">
          <a
            href="/api/health"
            className="px-4 py-2 bg-primary text-primary-foreground rounded-md hover:opacity-90"
          >
            API Health
          </a>
          <a
            href="/login"
            className="px-4 py-2 bg-secondary text-secondary-foreground rounded-md hover:opacity-90"
          >
            Login
          </a>
        </div>
      </div>
    </main>
  );
}
