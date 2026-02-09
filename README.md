# Otogamer-Toolbox (音游工具箱)

一款高颜值的 Maimai & Chunithm 游戏工具箱。
基于 Flutter 开发，主打玻璃拟态设计与流畅的物理动画，提供查分、推分及数据迁移等功能。

---

## 🏗 Architecture Tree (架构树)

本项目严格遵循分层架构设计。所有贡献代码必须严格归属于以下结构层级：

```plaintext
lib/
├── main.dart                  # 应用入口 (Application Entry Point)
├── kernel/                    # 核心逻辑层 (Core Logic / Business Logic)
│   ├── config/                # 应用配置 (App Configuration)
│   ├── di/                    # 依赖注入 (Dependency Injection - GetIt)
│   ├── mechanics/             # 游戏特定算法 (Game Algorithms)
│   ├── models/                # 数据模型 (Data Models / JSON Serialization)
│   ├── services/              # API 服务与后端逻辑 (API Services)
│   └── state/                 # 状态管理 (State Management - Provider)
│
└── ui/                        # 表现层 (Presentation Layer)
    ├── kit/                   # 设计系统与组件库 (Design System)
    │   ├── foundation/        # 设计基础 (Tokens: Colors, Typography, Themes)
    │   └── components/        # 可复用 UI 组件 (Atomic Design)
    │       ├── atoms/         # 原子组件 (Buttons, Inputs, Icons)
    │       ├── molecules/     # 分子组件 (Cards, Toasts, Dialogs)
    │       └── background/    # 动态背景 (Animated Backgrounds)
    │
    └── pages/                 # 下游业务页面 (Feature Pages)
        ├── home/              # 仪表盘与导航 (Dashboard)
        ├── login/             # 认证流程 (Authentication)
        ├── transfer/          # 数据迁移工具 (Data Transfer Tools)
        └── settings/          # 应用设置 (Application Settings)
```

> **注意**: 旧版文件夹 (`lib/views/`, `lib/widgets/`) 已被废弃。**严禁**向其中添加新代码，请优先使用上述新架构。

---

## 🛠 Tech Stack (技术栈)

- **核心框架**: Flutter (Dart 3.x)
- **状态管理**: `provider`
- **网络请求**: `dio`
- **依赖注入**: `get_it`, `injectable`
- **UI 哲学**: 自定义组件系统，纯代码实现高性能动画 (Pure Programmatic Animations)。

## 🚀 Getting Started (快速开始)

1.  **环境准备**:
    - Flutter SDK (Stable Channel, 最新版)
    - Visual Studio Code (推荐编辑器)

2.  **安装依赖**:

    ```bash
    flutter pub get
    flutter run
    ```

3.  **代码风格**:
    - 遵循标准 Dart lints 规范。
    - 优先考虑代码的可读性和模块化。

---
