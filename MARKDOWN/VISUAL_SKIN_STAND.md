# 构建与视觉规范：主题系统 (v4.0)

## 1. 主题注册方案 (Registry Strategy)

- **物理隔离**：所有背景/皮肤定义必须存放于 `lib/ui/design_system/theme/` 下的 `universal_theme/`（全局）或 `domain_theme/`（领域特定）目录。
- **手动登记 (当前)**：新建背景类后，需在 `lib/ui/design_system/theme/theme_catalog.dart` 的 `allThemes` 字典中手动实例化该类。
- **自动化预想 (Phase 2)**：未来将引入 `build_runner` 扫描注解，实现新建文件即自动收录。

## 2. 颜色配置策略 (Color Configuration)

- **三色体系**：每个主题必须严格定义并导出 `dark` (强调色/投影)、`medium` (BASIC 核心色)、`light` (背景/弱化色) 三种变体。
- **存储逻辑**：
  - **默认值 (Hardcoded)**：定义在各皮肤类 `.dart` 的构造函数中。
  - **自定义 (User Override)**：存储于 `JSON/SKIN_COLOR.json` 中。
- **加载优先级**：`用户自定义 (JSON)` > `出厂默认 (Dart)`。
- **持久化机制**：采用 500ms 防抖自动写入，用户修改面板后无需手动保存。

## 3. 组件引用原则 (Component Reference)

- **DI/注入机制**：所有业务组件禁止直接 hardcode 颜色，必须且只能通过 `Theme.of(context).extension<AppTheme>()` 获取当前上下文激活的皮肤对象。
- **典型引用场景**：
  - **背景**：由 `RootPage` 统一负责调用 `buildBackground` 渲染。
  - **文字/图标**：优先使用 `medium` (BASIC) 颜色作为高亮/激活态。
  - **装饰物**：使用 `dark` 配合透明度作为 Shadow 或边框色彩。

---

# 主题列表

## 全局主题

- 暗色星轨✅️

## 舞萌主题

- Circle✅️
- Prism Plus
- Prism
- Buddies Plus
- Buddies
- Festival Plus
- Festival
- Universe
- Splash Plus
- Splash
- DX

## 中二主题

- Verse✅️
