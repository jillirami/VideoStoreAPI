require "date"

class RentalsController < ApplicationController
  def checkout
    rental = Rental.new(rental_params)
    rental.checkout_date = Date.today
    rental.due_date = Date.today + 1.week

    movie = Movie.find_by(id: rental_params[:movie_id])

    unless movie 
      render json: { ok: false, errors: rental.errors.messages },
             status: :bad_request
      return
    end

    if rental.save
      movie.reduce_inventory
      render json: rental.as_json(only: [:customer_id, :movie_id]), status: :ok
    else
      render json: { ok: false, errors: rental.errors.messages },
             status: :bad_request
    end
  end

  def checkin
    rental = Rental.find_by(customer_id: params[:customer_id], movie_id: params[:movie_id])

    if rental
      if rental.update(checkin_date: Date.today)
        movie = Movie.find(rental.movie_id)
        movie.increase_inventory
        render json: rental.as_json(only: [:customer_id, :movie_id]), status: :ok
      else
        render json: { ok: false, errors: rental.errors.messages },
               status: :bad_request
      end
    else
      render json: { ok: false, errors: { rental: ["Rental not found"] } },
             status: :not_found
    end
  end

  private

  def rental_params
    return params.permit(:movie_id, :customer_id)
  end
end
