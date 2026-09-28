// 官方 uniterm 主题色板移植(style.css :root 实测提取)
export class UniTheme {
  bgBase: number
  bgElevated: number
  bgSurface: number
  bgOverlay: number
  textPrimary: number
  textSecondary: number
  accent: number
  border: number

  constructor(bgBase: number, bgElevated: number, bgSurface: number, bgOverlay: number,
    textPrimary: number, textSecondary: number, accent: number, border: number) {
    this.bgBase = bgBase
    this.bgElevated = bgElevated
    this.bgSurface = bgSurface
    this.bgOverlay = bgOverlay
    this.textPrimary = textPrimary
    this.textSecondary = textSecondary
    this.accent = accent
    this.border = border
  }
}

export const THEME_DARK: UniTheme = new UniTheme(0x14171d, 0x191c24, 0x1f222b, 0x252933, 0xe6e8ed, 0x9ea3ae, 0x22d3ee, 0x2a2f3a)
export const THEME_NAVY: UniTheme = new UniTheme(0x0f172a, 0x111c33, 0x16233f, 0x1b2b4d, 0xe2e8f0, 0x94a3b8, 0x38bdf8, 0x243252)
export const THEME_LIGHT: UniTheme = new UniTheme(0xf5f6f8, 0xffffff, 0xffffff, 0xffffff, 0x1f2430, 0x5f6672, 0x0891b2, 0xdfe3ea)

export function themeByName(name: string): UniTheme {
  if (name === 'navy') {
    return THEME_NAVY
  }
  if (name === 'light') {
    return THEME_LIGHT
  }
  return THEME_DARK
}
