
# Stardust-Core

从零开始手写的 RISC-V CPU 核心系列，以恒星的名称做为微架构代号。

## 微架构

| 代号 | 中文名 | 说明 | 状态 |
|:---:|:---|:---|:---:|
| **Procyon** | 南河三 | 第一代：多周期设计，指令周期为 5 个时钟周期，指令集支持 RV32I 指令集，后续会逐步增加指令集的支持。 |  开发中 |

## 目录结构

```
Stardust-Core/
├── Procyon/
│   ├── src/
│   ├── tb/
│   └── constraints/
├── docs/
└── README.md
```

## 许可证

Copyright (c) 2026 mio-qwq. All Rights Reserved.
