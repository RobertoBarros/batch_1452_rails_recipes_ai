require "open-uri"

class Recipe < ApplicationRecord
  has_one_attached :photo

  after_save if: -> { saved_change_to_name? || saved_change_to_ingredients? } do
    set_content
    set_photo
  end

  def content
    if super.blank?
      set_content
    else
      super
    end
  end

  private

  def set_content
    sleep 1
    client = OpenAI::Client.new
    chaptgpt_response = client.chat(parameters: {
      model: "gpt-3.5-turbo",
      messages: [{ role: "user", content: "Give me a simple recipe for #{name} with the ingredients #{ingredients}. Give me only the text of the recipe, without any of your own answer like 'Here is a simple recipe'."}]
    })
    new_content = chaptgpt_response["choices"][0]["message"]["content"]

    update(content: new_content)
    return new_content
  end

  def set_photo
    sleep 1
    client = OpenAI::Client.new
    response = client.images.generate(parameters: {
      prompt: "A recipe image of #{name} with ingredients #{ingredients}", size: "1024x1024", quality: "standard", model: 'dall-e-3'
    })

    url = response["data"][0]["url"]
    file = URI.open(url)

    photo.purge if photo.attached?
    photo.attach(io: file, filename: "ai_generated_image.jpg", content_type: "image/png")
    return photo
  end

end
