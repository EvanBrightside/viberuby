module Viberuby
  class Client
    def initialize(token)
      @token = token
      @default_headers = { x_viber_auth_token: @token }
      @default_params = {
        min_api_version: 1,
        tracking_data: 'message to client'
      }
    end

    def set_webhook(url = '')
      post('set_webhook', { url: url }.to_json, content_type: :json, accept: :json)
    end

    def send_message(arguments)
      message_params = {
        type: :text
      }.merge(arguments)
      post('send_message', @default_params.merge(message_params).to_json, content_type: :json, accept: :json)
    end

    def send_file(recipient_id, file_data, file_path, file_type, kbd)
      message_params = {
        receiver: recipient_id,
        media: file_path,
        keyboard: kbd
      }

      file_type = file_type.split('/')[0]

      case file_type
      when 'image'
        message_params[:text] = ''
        message_params[:type] = :picture
      when 'video'
        message_params[:type] = :video
        message_params[:size] = file_data.size
      else
        message_params[:type] = :file
        message_params[:size] = file_data.size
        message_params[:file_name] = file_data.file.filename
      end
      post('send_message', @default_params.merge(message_params).to_json, content_type: :json, accept: :json)
    end

    def get_account_info
      post('get_account_info', {}.to_json, content_type: :json, accept: :json)
    end

    private

    def post(endpoint, payload, custom_headers = {})
      with_retries(3) do
        RestClient.post(ViberApi::API_URL + endpoint, payload, @default_headers.merge(custom_headers))
      end
    end

    def with_retries(retries_count = 5)
      retries_count -= 1
      response = yield
      response_body = JSON.parse(response.body)
      check_status_code(response_body)
      response_body
    rescue => e
      raise e if e.class.name.start_with? 'ViberApiException'

      raise ViberNetworkException, "Message: #{e.message}. Number of connection tries exceed." unless retries_count > 0

      sleep(5)
      retry
    end

    # Viber always responds 200 'OK' by HTTP so we need to check status in response body.
    def check_status_code(response_body)
      error_code = response_body['status'].to_i
      error = ViberApi::ERROR_CODES[error_code] || { name: :generalError, description: 'General error.' }
      raise ViberApiException, "Viber error. Response code: #{error_code}. Name: #{error[:name]}. Description: #{error[:description]}." unless error_code.zero?

      true
    end
  end
end

API_URL = 'https://chatapi.viber.com/pa/'
ERROR_CODES = [
  { name: :ok, desription: 'Success' },
  { name: :invalidUrl, description: 'The webhook URL is not valid' },
  { name: :invalidAuthToken, description: 'The authentication token is not valid' },
  { name: :badData, description: 'There is an error in the request itself (missing comma, brackets, etc.)' },
  { name: :missingData, description: 'Some mandatory data is missing' },
  { name: :receiverNotRegistered, description: 'The receiver is not registered to Viber' },
  { name: :receiverNotSubscribed, description: 'The receiver is not subscribed to the PA' },
  { name: :publicAccountBlocked, description: 'The public account is blocked' },
  { name: :publicAccountNotFound, description: 'The account associated with the token is not a public account' },
  { name: :publicAccountSuspended, description: 'The public account is suspended' },
  { name: :webhookNotSet, description: 'No webhook was set for the public account' },
  { name: :receiverNoSuitableDevice, description: "The receiver is using a device or a Viber version that don't support public accounts" },
  { name: :tooManyRequests, description: 'Rate control breach' },
  { name: :apiVersionNotSupported, description: "Maximum supported PA version by all user's devices is less than the minApiVersion in the message" },
  { name: :incompatibleWithVersion, description: 'minApiVersion is not compatible to the message fields' }
]

class ViberApiException < StandardError; end
class ViberNetworkException < StandardError; end
