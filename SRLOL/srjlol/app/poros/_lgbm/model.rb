module Lgbm
    class Model
        include HTTParty

        base_uri (ENV["SRJLOL_LGBM_URL"] || "http://127.0.0.1:8080")

        # predictions URI PATH
        PREDICT_PATH = "/predictions"

        # :predict
        # consumes the service of predictions sending a post request with the @body input
        def predict(body = {})
            parse_response(self.class.post(
                PREDICT_PATH, body: body.to_json, headers: {"Content-Type": "application/json", "Accept": "*/*"}
            ))
        end 
        
        private 

        # :parse_response
        # Parse the response from the service @httparty_response to a hash with symbols.
        def parse_response(httparty_response)
            if httparty_response.code == 200
                response = httparty_response.parsed_response
                return [true, response]
            else 
                return [false, response]
            end 
        end 
    end 
end 