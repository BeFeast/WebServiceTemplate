I want a few slash commands in ~/.factory folder on devbox (10.10.0.13):
- /dev-scaffold <name of the project> - create from gh template full project in /opt/projects/<name of the project>
- /dev-run (to run scaffolded project, in the current dir)
- /dev-deploy (create docker compose stack with containers of the project - fe, be, others if any)

Because this template is specifically written for DevBox and local infrastructure, we can assume:
- all scripts are running on 10.10.0.13 (Ubuntu 24.04.3 LTS 24.04.3 LTS Noble Numbat)
- we can now install all tools needed for running web service
- all services use Postgres and Redis shared on portainer stack `ok-shared-infra`, ok-postgres and ok-redis, respectively
 
Trying to vibe code previously with claude code cli and droid, i find that usually with auth and frontend-backend communications, there are always errors due to url/path rewriting, e.g. /api/v1/health goes to /v1/health and so.
We have NPM, so fix can be two fold: for IP-based access (lets discuss if needed) it's ports, and for domain-name based (configured on NPM) - it can be project-name.oklabs.uk for fe, and project-name-api.oklabs.uk for be that points to the appropriate ports