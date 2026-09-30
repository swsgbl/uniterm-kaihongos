// 官方 uniterm 主题色板(start_tab.webp 像素实测 2026-09-28 relay2)
// M6 relay1: 新增语义色 token——success/warn/danger 状态色、inputBg 输入底、iconMuted 图标未选中色,
// 供 18 个子组件统一取色,消灭各自硬编码 0x 色值(P0-4)。
export class UniTheme {
  bgBase: number
  bgElevated: number
  bgSurface: number
  bgOverlay: number
  textPrimary: number
  textSecondary: number
  accent: number
  border: number
  success: number
  warn: number
  danger: number
  inputBg: number
  iconMuted: number

  constructor(bgBase: number, bgElevated: number, bgSurface: number, bgOverlay: number,
    textPrimary: number, textSecondary: number, accent: number, border: number,
    success: number, warn: number, danger: number, inputBg: number, iconMuted: number) {
    this.bgBase = bgBase
    this.bgElevated = bgElevated
    this.bgSurface = bgSurface
    this.bgOverlay = bgOverlay
    this.textPrimary = textPrimary
    this.textSecondary = textSecondary
    this.accent = accent
    this.border = border
    this.success = success
    this.warn = warn
    this.danger = danger
    this.inputBg = inputBg
    this.iconMuted = iconMuted
  }
}

// dark: 深灰蓝底/浅字/青 accent(官方默认);inputBg 深于 surface,iconMuted 中灰
export const THEME_DARK: UniTheme = new UniTheme(0x15191f, 0x15191f, 0x21242c, 0x252933,
  0xe6e8ed, 0x8b999e, 0x22d3ee, 0x2a2f3a, 0x34d399, 0xf59e0b, 0xf87171, 0x1f222b, 0xaeb6bf)
// navy: 深蓝底/天蓝 accent
export const THEME_NAVY: UniTheme = new UniTheme(0x0f172a, 0x111c33, 0x16233f, 0x1b2b4d,
  0xe2e8f0, 0x94a3b8, 0x38bdf8, 0x243252, 0x34d399, 0xf59e0b, 0xf87171, 0x131d33, 0x9aa8c0)
// light: 白底/深字/Windows 蓝 accent(relay6 官方浅色 token 实测);iconMuted 深灰
export const THEME_LIGHT: UniTheme = new UniTheme(0xffffff, 0xf5f5f5, 0xebebeb, 0xe0e0e0,
  0x1a1a1a, 0x5a5a5a, 0x0078d4, 0xe0e0e0, 0x108038, 0xb45309, 0xc62828, 0xf6f8fa, 0x5a5a5a)

export function themeByName(name: string): UniTheme {
  if (name === 'navy') {
    return THEME_NAVY
  }
  if (name === 'light') {
    return THEME_LIGHT
  }
  return THEME_DARK
}
