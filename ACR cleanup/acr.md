# 📘 Azure Container Registry (ACR) — Image Cleanup Task Documentation

This document explains how to create and manage an **Azure Container Registry (ACR) Task** that automatically removes **untagged images older than 365 days**.

The task runs **weekly** using a CRON schedule.

---

## 🧩 **Prerequisites**

Before running the commands:

* Azure CLI installed
* Logged in to Azure (`az login`)
* Required variables:

```powershell
$acrName="yourACRName"
$taskName="acrCleanupTask"
```

---

# 🚀 1. Create an ACR Task for Automated Image Cleanup

The following command creates a task that purges:

* **Untagged images only**
* **Older than 365 days**
* Across **all repositories** in ACR
* Runs **every Sunday at 00:00 UTC**

```powershell
az acr task create `
  --registry $acrName `
  --name $taskName `
  --cmd "acr purge --filter '.*:.*' --ago 365d --untagged" `
  --schedule "0 0 * * 0" `
  --context /dev/null `
  --platform linux
```

### 📌 Explanation of parameters

| Parameter                | Description                                     |
| ------------------------ | ----------------------------------------------- |
| `--registry`             | Name of Azure Container Registry                |
| `--name`                 | Task name                                       |
| `--cmd`                  | Cleanup command                                 |
| `acr purge`              | Built-in utility to delete old/unwanted images  |
| `--filter '.*:.*'`       | Applies purge rule to all repositories and tags |
| `--ago 365d`             | Deletes images older than 365 days              |
| `--untagged`             | Deletes only untagged images                    |
| `--schedule "0 0 * * 0"` | CRON schedule: runs every Sunday 00:00 UTC      |
| `--context /dev/null`    | No Git repository required                      |
| `--platform linux`       | Uses Linux execution environment                |

---

# 📄 2. List All Tasks in the ACR

Displays all tasks created inside the registry.

```powershell
az acr task list --registry $acrName --output table
```

---

# 📜 3. View Logs for the Cleanup Task

Shows execution logs for the specific task.

```powershell
az acr task logs --registry $acrName --name $taskName
```

---

# ▶️ 4. Run the Cleanup Task Manually

You can trigger the task immediately without waiting for the schedule.

```powershell
az acr task run --registry $acrName --name $taskName
```

---

# 🗑 5. Delete the Cleanup Task

To remove the task from ACR:

```powershell
az acr task delete --registry $acrName --name $taskName
```

---

# 📦 Summary

| Task                | Command              |
| ------------------- | -------------------- |
| Create cleanup task | `az acr task create` |
| List tasks          | `az acr task list`   |
| View logs           | `az acr task logs`   |
| Run task manually   | `az acr task run`    |
| Delete task         | `az acr task delete` |