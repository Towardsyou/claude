# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal Claude configuration repository containing custom agents, skills, and workflows for complex task orchestration. The project is primarily focused on Claude Code customization rather than a traditional software application.

## Repository Structure

- `.claude/agents/` - Custom agent definitions with specialized capabilities
- `.claude/skills/` - Custom skill definitions (if present)
- `README.md` - Project documentation in Chinese
- `CLAUDE.md` - This guidance file

## Key Components

### Custom Agents

The repository includes specialized agents, most notably:

- **golang-backend-developer** (.claude/agents/golang-backend-developer.md) - Expert Golang backend development agent with DDD architecture focus, enterprise-grade security practices, and comprehensive testing strategies (unit/integration/E2E).

### Agent Capabilities

The golang-backend-developer agent specializes in:
- Backend API development with Gin framework
- DDD architecture (handler -> service -> repo -> storage)
- Security implementation (OWASP guidelines, XSS prevention, input validation)
- Three-tier testing hierarchy with mocks and performance testing
- Production readiness including Docker, monitoring, and OpenAPI documentation

## Development Workflow

Since this is a configuration repository for Claude Code:
1. Agents are defined in Markdown with YAML frontmatter
2. Each agent has specific model inheritance and color coding
3. Agents contain detailed instructions for their domain expertise
4. No traditional build/test commands - this is a configuration-only repository

## Usage Notes

- This repository configures Claude Code behavior rather than containing executable code
- Custom agents enhance Claude Code's capabilities for specific domains
- The golang-backend-developer agent is particularly useful for backend API projects
- All documentation is in Chinese except for this guidance file

## Others

- 使用中文回答