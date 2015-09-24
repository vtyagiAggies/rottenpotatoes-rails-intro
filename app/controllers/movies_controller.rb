class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratings  
    @movies = Movie.all
    @sort_by = params[:sort_by]
    if(@sort_by != nil)
	session[:sort_by] = @sort_by
    end

    if(params[:ratings] == nil && params[:sort_by] == nil && session[:saved_params] == nil )
	@movies = Movie.all
	@selected_ratings = @all_ratings
    end
    if(params[:ratings] != nil || params[:sort_by] != nil)  #If parameter exist assign them to session
	session[:saved_params] = session[:saved_params].present? ? session[:saved_params] : {}
	if (params[:sort_by] != nil && params[:sort_by].length != 0)
		session[:saved_params][:sort_by] = params[:sort_by]
	elsif (session[:saved_params] != nil && session[:saved_params].length != 0)
		params[:sort_by]  = session[:saved_params][:sort_by]
	end
	if (params[:ratings] != nil)	
		session[:saved_params][:ratings] = params[:ratings]
	end
    elsif (session[:saved_params] != nil && session[:saved_params].length != 0) #if parameter doesn't exist but session exist redirect using session values
	flash.keep
	redirect_to movies_path + '?' + session[:saved_params].to_query
    end

    
    if(session[:saved_params])
    	@selected_ratings = (session[:saved_params][:ratings].present? ? session[:saved_params][:ratings].keys : @all_ratings)
	if(@sort_by == nil)
		@sort_by = session[:saved_params][:sort_by] ? session[:saved_params][:sort_by] : params[:sort_by]
	end
    else
	@selected_ratings = @all_ratings
        @sort_by = params[:sort_by]
    end

    @sort_by = session[:sort_by]
    if(@sort_by != nil)
	@movies = Movie.where(:rating =>@selected_ratings).order(@sort_by)
    else
	@movies = Movie.where(:rating =>@selected_ratings)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
