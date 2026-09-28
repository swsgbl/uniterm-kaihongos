// LLM 配置持久化(filesDir/llm_config.json)
import fs from '@ohos.file.fs';
import { LlmConfig } from './Llm';

export class LlmConfigStore {
  private static path(filesDir: string): string {
    return filesDir + '/llm_config.json'
  }

  static read(filesDir: string): LlmConfig {
    const p = LlmConfigStore.path(filesDir)
    if (!fs.accessSync(p)) {
      return { provider: 'anthropic', baseUrl: 'https://api.anthropic.com', apiKey: '', model: 'claude-sonnet-4-5' }
    }
    try {
      const raw = fs.readTextSync(p)
      return JSON.parse(raw) as LlmConfig
    } catch (e) {
      return { provider: 'anthropic', baseUrl: 'https://api.anthropic.com', apiKey: '', model: 'claude-sonnet-4-5' }
    }
  }

  static write(filesDir: string, cfg: LlmConfig): void {
    try {
      const p = LlmConfigStore.path(filesDir)
      const f = fs.openSync(p, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC)
      fs.writeSync(f.fd, JSON.stringify(cfg))
      fs.closeSync(f)
    } catch (e) {
    }
  }
}
