class ChatUpdater
  include Sidekiq::Worker
  sidekiq_options queue: 'updating'

  def perform(options)
    chat = Chat.find_by(id: options['id'])
    return if chat.nil?
    meta = { title: options['title'],
             first_name: options['first_name'],
             last_name: options['last_name'],
             username: options['username'],
             kind: options['kind'] }
    chat.update_meta(meta)
  end
end
