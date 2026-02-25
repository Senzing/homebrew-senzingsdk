# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a **template repository** for Senzing Garage projects. It contains exemplar artifacts (standard files) that other repositories should include: README, CONTRIBUTING, CODE_OF_CONDUCT, LICENSE, CHANGELOG, and GitHub workflows.

## CI/CD and Automation

GitHub Actions workflows use reusable workflows from [senzing-factory/build-resources](https://github.com/senzing-factory/build-resources):

- **lint-workflows.yaml**: Runs super-linter on pushes to non-main branches and PRs to main
- **spellcheck.yaml**: Runs cspell on PRs to main
- **claude-pr-review.yaml**: Automated Claude PR review on opened/synchronized PRs
- **dependabot-approve-and-merge.yaml**: Auto-approves and merges dependabot PRs
- **add-labels-standardized.yaml**: Adds labels to new issues
- **add-to-project-garage.yaml**: Adds issues to the Garage project board

## CHANGELOG Convention

CHANGELOG.md follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format with [Semantic Versioning](https://semver.org/). Changes are manually curated (not auto-generated) to describe user-facing impacts.

## Claude Slash Commands

- `/senzing` - Runs steps from the centralized senzing command
