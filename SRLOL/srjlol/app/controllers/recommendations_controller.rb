class RecommendationsController < ApplicationController

    # Endpoint of the recomendations service. It Attends the client request and creates the recomendation
    def create
        recommendation = Recommendation.generate(recommend_params)
        render json: recommendation.output_response, status: recommendation.predicted? ? 200 : 422
    end 

    private

    # :recomended_params
    # this method filter the parameters sent in the request to allow only the permitted ones.
    # other attributes will be removed.
    def recommend_params
        params.require(:recommendation).permit(
            :minute, 
            :building_mid, 
            :deaths_MIDDLE, 
            :deaths_BOTTOM,
            :heralds, 
            :total_gold_MIDDLE, 
            :deaths_JUNGLE, 
            :kills_JUNGLE,
            :deaths_TOP, 
            :kills_TOP, 
            :building_top,
            :physicalDamageTaken_MIDDLE, 
            :kills_BOTTOM, 
            :kills_MIDDLE,
            :building_bot, 
            :assists_UTILITY, 
            :deaths_UTILITY,
            :minionsKilled_MIDDLE, 
            :magicDamageDoneToChampions_MIDDLE
        )
    end 
end
