class FizzBuzzController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    return if params[:number].blank?

    number = params[:number].to_i
    @result = if number % 15 == 0
      "FizzBuzz"
    elsif number % 3 == 0
      "Fizz"
    elsif number % 5 == 0
      "Buzz"
    else
      number.to_s
    end
  end
end
