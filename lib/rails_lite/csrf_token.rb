class CSRFToken
  def initialize
    @session_tokens = {}
  end

  def generate_token(session_id)
    token = SecureRandom.urlsafe_base64
    @session_tokens[session_id] = token
    token
  end

  def has_token?(session_id)
    @session_tokens.has_key?(session_id)
  end

  def valid_token?(session_id, token)
    @session_tokens[session_id] == token
  end

  def discard_token(session_id)
    @session_tokens.delete(session_id)
  end
end
