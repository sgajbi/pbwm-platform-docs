# Platform Standards

This folder is the reusable standards package for backend repositories.

## Contents

- `templates/Makefile.backend.template`
- `templates/pre-commit.backend.template.yaml`
- `templates/workflows/ci.backend.template.yml`
- `templates/workflows/pr-auto-merge.template.yml`

## Usage

1. Copy templates into service repositories.
2. Adapt only repo-specific values (branch name, Python version, docker image tag, test paths).
3. Keep required gate names and required `make` targets unchanged.
4. Run conformance validator:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Validate-Backend-Standards.ps1
```

