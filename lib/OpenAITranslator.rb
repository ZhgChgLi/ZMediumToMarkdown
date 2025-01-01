require "openai"

class OpenAITranslator
    attr_accessor :prompt, :model, :client

    def initialize(model, token, prompt)
        @client = OpenAI::Client.new(access_token: token)
        @prompt = prompt
        @model = model
    end

    def translate(text)
        response = client.chat(
            parameters: {
              model: model,
              messages: [
                { role: "system", content: "You are a translation expert." },
                { role: "user", content: prompt },
                { role: "user", content: text}
              ],
              temperature: 0.7,
            }
        )

        response.dig("choices", 0, "message", "content")
    end
end