require 'rubygems'
require 'json'

class SearchesController < ApplicationController
  #before_action :set_search, only: [:show, :edit, :update, :destroy]
  before_action :set_search, only: [:edit, :update]

  # GET /searches
  # GET /searches.json
  def index
    @searches = Search.all
  end

  # GET /searches/1
  # GET /searches/1.json
  def show
    search = Search.find(params[:id])
    @issues = getGitIssues(search.keyword, search.language, search.order)
    puts @issues
  end

  # GET /searches/new
  def new
    @search = Search.new
  end

  # GET /searches/1/edit
  def edit
    #search = Search.find(params[:id])
    search = Search.first
    @issues = getGitIssues(search.keyword, search.language, search.order)
  end

  def getListOf(json, key)
    values = []
    if json != nil
      json.each {
        |x| values.push(x[key])
      }
    end
    return values
  end

  def getGitIssues(topic, lang, order)
    url = "\"https://api.github.com/search/issues?q=" + topic + "+label:bug+language:" + lang + "+state:open&sort=" + order + "&order=desc\" -H 'Accept: application/vnd.github.preview'"
    data = `curl -i #{url} 2> /dev/null`
    j = data.index("{")
    raw = data[j..data.length-1]
    items = JSON.parse(raw)["items"]
    titles = getListOf(items, "title")
    urls = getListOf(items, "url")
    html_urls = getListOf(items, "html_url")

    issues = []
    urls.each {
      |x| i = x.index("/issue")
      repo = x[0..i-1]
      userAndName = repo[(repo.index("repos/") + 6)..repo.length-1]
      i = userAndName.index("/")
      repoName = userAndName[i+1..repo.length-1]
      j = urls.index(x)
      issues.push([repoName, titles[j], html_urls[j]])
    }
    return issues
  end

  # POST /searches
  # POST /searches.json
  def create
    @search = Search.new(search_params)

    respond_to do |format|
      if @search.save
        #format.html { redirect_to @search, notice: 'Search was successfully created.' }
        format.html { redirect_to @search }
        format.json { render action: 'edit', status: :created, location: @search }
      else
        format.html { render action: 'new' }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /searches/1
  # PATCH/PUT /searches/1.json
  def update
    respond_to do |format|
      if @search.update(search_params)
        format.html { redirect_to :root }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /searches/1
  # DELETE /searches/1.json
  def destroy
    @search.destroy
    respond_to do |format|
      format.html { redirect_to searches_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_search
      #@search = Search.find(params[:id])
      @search = Search.first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params.require(:search).permit(:keyword, :language, :order)
    end
end
