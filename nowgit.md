# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | ClearSpend |
| **Git URL** | git@github.com:asunnyboy861/ClearSpend.git |
| **Repo URL** | https://github.com/asunnyboy861/ClearSpend |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/ClearSpend/ | ⏳ Pending |
| Support | https://asunnyboy861.github.io/ClearSpend/support.html | ⏳ Pending |
| Privacy Policy | https://asunnyboy861.github.io/ClearSpend/privacy.html | ⏳ Pending |
| Terms of Use | https://asunnyboy861.github.io/ClearSpend/terms.html | ⏳ Pending (subscription app) |

## Repository Structure

```
ClearSpend/
├── ClearSpend/                          # iOS App Source Code
│   ├── ClearSpend.xcodeproj/            # Xcode Project
│   ├── ClearSpend/                      # Swift Source Files
│   │   ├── Views/
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── ViewModels/
│   │   ├── Utilities/
│   │   └── ...
│   └── ...
├── docs/                                # Policy Pages (GitHub Pages source)
│   ├── index.html                       # Landing Page
│   ├── support.html                     # Support Page
│   ├── privacy.html                     # Privacy Policy
│   └── terms.html                       # Terms of Use (subscription app)
├── .github/workflows/
│   └── deploy.yml                       # GitHub Pages deployment
├── us.md                                # English Development Guide
├── keytext.md                           # App Store Metadata
├── capabilities.md                      # Capabilities Configuration
├── icon.md                              # App Icon Details
├── price.md                             # Pricing Configuration
└── nowgit.md                            # This File
```
