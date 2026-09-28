// LLM 接入:官方兼容 Anthropic / OpenAI 协议(设置中配 base URL + key + model)
import http from '@ohos.net.http';

export class LlmConfig {
  provider: string = 'anthropic'
  baseUrl: string = 'https://api.anthropic.com'
  apiKey: string = ''
  model: string = 'claude-sonnet-4-5'
}

export class LlmMsg {
  role: string = 'user'
  text: string = ''
}

class AnthMsg {
  role: string = 'user'
  content: string = ''
}

class AnthBody {
  model: string = ''
  max_tokens: number = 1024
  system: string = ''
  messages: AnthMsg[] = []
}

class OaiMsg {
  role: string = 'user'
  content: string = ''
}

class OaiBody {
  model: string = ''
  max_tokens: number = 1024
  messages: OaiMsg[] = []
}

export class Llm {
  static async chat(cfg: LlmConfig, msgs: LlmMsg[], system: string): Promise<string> {
    if (cfg.provider === 'anthropic') {
      return Llm.anthropic(cfg, msgs, system)
    }
    return Llm.openai(cfg, msgs, system)
  }

  private static async anthropic(cfg: LlmConfig, msgs: LlmMsg[], system: string): Promise<string> {
    const body = new AnthBody()
    body.model = cfg.model
    body.system = system
    for (const m of msgs) {
      const a = new AnthMsg()
      a.role = m.role
      a.content = m.text
      body.messages.push(a)
    }
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'x-api-key': cfg.apiKey,
      'anthropic-version': '2023-06-01'
    }
    const resp = await Llm.post(cfg.baseUrl.replace(/\/+$/, '') + '/v1/messages', JSON.stringify(body), headers)
    class AnthPart { type: string = ''; text: string = '' }
    class AnthResp { content: AnthPart[] = [] }
    const obj = JSON.parse(resp) as AnthResp
    if (obj.content.length === 0) {
      throw new Error('anthropic bad resp: ' + resp.substring(0, 200))
    }
    let out = ''
    for (const p of obj.content) {
      if (p.type === 'text') {
        out += p.text
      }
    }
    return out
  }

  private static async openai(cfg: LlmConfig, msgs: LlmMsg[], system: string): Promise<string> {
    const body = new OaiBody()
    body.model = cfg.model
    const sys = new OaiMsg()
    sys.role = 'system'
    sys.content = system
    body.messages.push(sys)
    for (const m of msgs) {
      const a = new OaiMsg()
      a.role = m.role
      a.content = m.text
      body.messages.push(a)
    }
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + cfg.apiKey
    }
    const resp = await Llm.post(cfg.baseUrl.replace(/\/+$/, '') + '/chat/completions', JSON.stringify(body), headers)
    class OaiMsgOut { content: string = '' }
    class OaiChoice { message: OaiMsgOut = new OaiMsgOut() }
    class OaiResp { choices: OaiChoice[] = [] }
    const obj = JSON.parse(resp) as OaiResp
    if (obj.choices.length === 0) {
      throw new Error('openai bad resp: ' + resp.substring(0, 200))
    }
    const c0 = obj.choices[0]
    return c0.message.content
  }

  private static async post(url: string, body: string, headers: Record<string, string>): Promise<string> {
    return new Promise<string>((resolve, reject) => {
      const h = http.createHttp()
      h.request(url, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: body,
        connectTimeout: 30000,
        readTimeout: 60000,
        expectDataType: http.HttpDataType.STRING
      }, (err, resp) => {
        h.destroy()
        if (err) {
          reject(new Error('http ' + JSON.stringify(err)))
          return
        }
        if (resp.responseCode >= 400) {
          let d = ''
          if (typeof resp.result === 'string') {
            d = resp.result
          }
          reject(new Error('http ' + resp.responseCode + ' ' + d.substring(0, 300)))
          return
        }
        resolve(typeof resp.result === 'string' ? resp.result : '')
      })
    })
  }
}
