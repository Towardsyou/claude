---
name: kubernetes-kubectl
description: Kubernetes kubectl 资源查询工具，用于查询 Pod 状态、日志、事件等各种 K8s 资源
examples:
  - "查询 default 命名空间下所有 Pod 状态"
  - "查看 nginx-app Pod 的最近日志"
  - "获取 my-namespace 命名空间下所有事件"
  - "检查所有节点的状态"
  - "查看指定 Deployment 的副本状态"
---

# Kubernetes kubectl 资源查询 Skill

这是一个专门用于通过 kubectl 查询 Kubernetes 集群资源的 skill。你可以查询 Pod 状态、日志、事件、节点状态等各种 K8s 资源信息。

## 主要功能

### 1. Pod 相关查询
- 查询 Pod 状态
- 获取 Pod 日志
- 查看 Pod 详细信息
- 查询 Pod 事件

### 2. 资源状态查询
- Deployment 状态
- Service 状态
- ConfigMap 和 Secret
- Ingress 状态

### 3. 集群级别查询
- 节点状态
- 命名空间信息
- 集群事件
- 资源使用情况

### 4. 日志和调试
- Pod 日志查询
- 容器日志查询
- 事件查询
- 资源描述信息

## 使用方法

你可以用自然语言描述你想要查询的内容，例如：

- "显示 default 命名空间下所有 Pod 的状态"
- "查看 web-app Pod 最近 100 行日志"
- "获取 production 命名空间下的所有事件"
- "检查所有节点的状态和资源使用情况"
- "查看 frontend Deployment 的副本状态"

## 支持的查询类型

1. **Pod 查询**：
   - Pod 状态、列表、详细信息
   - Pod 日志（支持行数限制、时间范围）
   - Pod 事件和问题诊断

2. **工作负载查询**：
   - Deployment、StatefulSet、DaemonSet
   - Job、CronJob 状态

3. **服务和网络查询**：
   - Service、Endpoint、Ingress
   - NetworkPolicy

4. **配置查询**：
   - ConfigMap、Secret
   - ResourceQuota、LimitRange

5. **集群资源查询**：
   - Node、Namespace、Event
   - PV、PVC、StorageClass

## 注意事项

- 确保 kubectl 已正确配置并能访问集群
- 支持指定命名空间进行查询
- 日志查询支持多种过滤选项
- 所有查询都会以清晰的格式展示结果