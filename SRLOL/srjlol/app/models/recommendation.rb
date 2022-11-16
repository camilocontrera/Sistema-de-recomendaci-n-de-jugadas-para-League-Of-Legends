# Recommendation model
class Recommendation 
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid

  # Constant with the statuses in which the recommendation can be.
  # pending: the recomendation hasn't been processed yet
  # predicted: the recomendation was processed with success
  # failed: A try to process the recomendation was made but was unsuccessful
  STATUSES = {
      pending: 0,
      predicted: 1,
      failed: 3
  }

  # Input sent by the client
  field :input_body, type: Hash
  # Output sent to the client
  field :output_response,type: Hash
  # timestamp in which the predictions service was called
  field :prediction_started_at
  # body of the resquest sent to the predictions service
  field :prediction_service_body, type: Hash
  # response of the predictions service
  field :prediction_service_response , type: Hash
  # timestamp in which the prediction responded
  field :prediction_ended_at
  # The value of the prediction returned by the predictions service
  field :prediction
  # the field with the status of the recomendation
  as_enum :status, STATUSES, field: {type: Integer, default: STATUSES[:pending]}

  index({created_at: 1})
  index({created_at: 1})
  index({status_cd: 1})

  # instance of the LightGBM model
  attr_accessor :lgbm_model

  # callback that initialize the LightGBM model instance with the recomendation
  after_initialize :setup_lgbm

  # :setup_lgbm
  # This metod initialize the LightGBM model instance
  def setup_lgbm
    @lgbm_model = Lgbm::Model.new
  end

  # :generate
  # This method will create the recomendation, calling the method :process
  # @params 
  # request_body: hash with the information to be send to the predictions service.
  def self.generate(request_body) 
    recomm = new
    recomm.input_body = request_body.to_h
    recomm.prediction_service_body = request_body.to_h
    recomm.process!
    recomm
  end 

  # :process
  # this method process the recomendations, adding the timestamps in which 
  # the predictions service was consumed and when it delivered the response.
  # It uses the #lgbm_model to consume the predictions service
  # also calls the method :parse_prediction to format the output in
  # naturla language
  def process 
    begin
      self.prediction_started_at = Time.now      
      success, aux_prediction = @lgbm_model.predict(self.prediction_service_body)      
      self.prediction_service_response = aux_prediction
      self.prediction_ended_at = Time.now
      if success
        self.prediction = aux_prediction["prediction"].first
        self.predicted!
      else
        self.failed!
      end 
      self.parse_prediction 
    rescue Exception => e
      self.failed!
      self.parse_prediction 
      self.save!
    end 
  end 

  # :process!
  # This methods saves the recomendation after the method :process it's called
  def process!
    begin
      self.process
      self.save!
    rescue Exception => e
      self.failed!
      self.save!
    end 
  end 

  # :parse_prediction
  # this method parse the prediction to natural language
  def parse_prediction
    if self.predicted?
      if self.prediction == 0
        self.output_response = { recommendation: "No tomes la torre de mid" }
      else 
        self.output_response = { recommendation: "Toma la siguiente torre de mid" }
      end 
    else 
      self.output_response = { mssg: "No pudimos generar una recomendación. Asegurese de enviar los datos de entrada en el formato correcto."}
    end 
  end 

  # :parse_prediction
  # this method will save the recomendation after the method :parse_prediction it's called
  def parse_prediction!
    self.parse_prediction
    self.save!
  end 
  
end
