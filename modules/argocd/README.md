app-of-apps
├── terraform/
│   └── main.tf (root app + Argo CD bootstrap)
├── root-app/ (path for app-of-apps.yaml)
│   └── app-of-apps.yaml
└── README.md

tenant-apps-git (platform-team sub repo)
├── platform-apps/ (shared infra apps)
│   ├── cert-manager.yaml
│   ├── external-dns.yaml
│   └── logging.yaml
├── tenant-a.yaml (points to tenant A's repo)
├── tenant-b.yaml (points to tenant B's repo)
└── README.md

tenant-a-git (tenant repo)
├── namespace.yaml
├── deployment.yaml
└── service.yaml
