"use client";

import { useMemo } from "react";

export default function Home() {
  const { apiUrl, frontendUrl } = useMemo(() => {
    if (typeof window === "undefined") {
      return { apiUrl: "", frontendUrl: "" };
    }
    const host = window.location.hostname;
    const isIP = /^\d+\.\d+\.\d+\.\d+$/.test(host);
    
    if (isIP) {
      return {
        apiUrl: `http://${host}:{{BACKEND_PORT}}`,
        frontendUrl: `http://${host}:{{FRONTEND_PORT}}`,
      };
    } else {
      const apiHost = host.replace(/^([^.]+)\./, "$1-api.");
      return {
        apiUrl: `${window.location.protocol}//${apiHost}`,
        frontendUrl: window.location.origin,
      };
    }
  }, []);

  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <div className="text-center">
        <h1 className="text-4xl font-bold mb-4">{"{{PROJECT_NAME}}"}</h1>
        <p className="text-muted-foreground mb-8">
          Full-stack application built with Next.js and FastAPI
        </p>
        
        <div className="flex gap-4 justify-center mb-8">
          <a
            href={`${apiUrl}/health`}
            target="_blank"
            rel="noopener noreferrer"
            className="px-4 py-2 bg-primary text-primary-foreground rounded-md hover:opacity-90"
          >
            API Health
          </a>
          <a
            href={`${apiUrl}/docs`}
            target="_blank"
            rel="noopener noreferrer"
            className="px-4 py-2 bg-secondary text-secondary-foreground rounded-md hover:opacity-90"
          >
            API Docs
          </a>
        </div>

        <div className="text-sm text-muted-foreground space-y-1">
          <p>Frontend: <code className="bg-muted px-1 rounded">{frontendUrl}</code></p>
          <p>Backend: <code className="bg-muted px-1 rounded">{apiUrl}</code></p>
        </div>
      </div>
    </main>
  );
}
