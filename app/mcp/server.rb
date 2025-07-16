#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'uri'
require 'sinatra/base'

class McpServer < Sinatra::Base
  set :port, 3001
  set :bind, '0.0.0.0'
  
  def initialize
    super
    @base_url = "http://localhost:3000/api"
    @tools = [
      {
        name: "register_user_skin_info",
        description: "사용자의 피부 정보를 등록합니다",
        inputSchema: {
          type: "object",
          properties: {
            skin_type: {
              type: "string",
              description: "피부 타입 (dry, oily, combination, sensitive)",
              enum: ["dry", "oily", "combination", "sensitive"]
            },
            concerns: {
              type: "string",
              description: "피부 고민사항 (쉼표로 구분: acne,aging,brightening,hydration)"
            },
            age_group: {
              type: "string",
              description: "연령대 (teens, twenties, thirties, forties_plus)",
              enum: ["teens", "twenties", "thirties", "forties_plus"]
            }
          },
          required: ["skin_type", "concerns", "age_group"]
        }
      },
      {
        name: "get_cosmetic_recommendations",
        description: "사용자에게 맞는 화장품을 추천합니다",
        inputSchema: {
          type: "object",
          properties: {
            user_id: {
              type: "integer",
              description: "사용자 ID"
            },
            ingredient: {
              type: "string",
              description: "특정 성분이 포함된 제품을 찾고 싶을 때 (선택사항)"
            }
          },
          required: ["user_id"]
        }
      },
      {
        name: "search_products",
        description: "화장품 제품을 검색합니다",
        inputSchema: {
          type: "object",
          properties: {
            query: {
              type: "string",
              description: "검색어 (제품명, 브랜드, 설명)"
            },
            category: {
              type: "string",
              description: "카테고리 필터"
            },
            brand: {
              type: "string",
              description: "브랜드 필터"
            },
            max_price: {
              type: "integer",
              description: "최대 가격"
            },
            min_price: {
              type: "integer",
              description: "최소 가격"
            }
          },
          required: ["query"]
        }
      },
      {
        name: "search_ingredients",
        description: "화장품 성분을 검색합니다",
        inputSchema: {
          type: "object",
          properties: {
            query: {
              type: "string",
              description: "검색어 (성분명, 설명, 효과)"
            },
            effect: {
              type: "string",
              description: "효과 필터"
            },
            safety_level: {
              type: "string",
              description: "안전도 필터"
            }
          },
          required: ["query"]
        }
      },
      {
        name: "get_products_by_ingredient",
        description: "특정 성분이 포함된 제품들을 찾습니다",
        inputSchema: {
          type: "object",
          properties: {
            ingredient_name: {
              type: "string",
              description: "성분명"
            },
            user_id: {
              type: "integer",
              description: "사용자 ID (선택사항 - 개인화된 추천을 위해)"
            }
          },
          required: ["ingredient_name"]
        }
      },
      {
        name: "get_user_profile",
        description: "사용자의 프로필 정보를 조회합니다",
        inputSchema: {
          type: "object",
          properties: {
            user_id: {
              type: "integer",
              description: "사용자 ID"
            }
          },
          required: ["user_id"]
        }
      },
      {
        name: "update_user_profile",
        description: "사용자의 프로필 정보를 업데이트합니다",
        inputSchema: {
          type: "object",
          properties: {
            user_id: {
              type: "integer",
              description: "사용자 ID"
            },
            skin_type: {
              type: "string",
              description: "피부 타입"
            },
            concerns: {
              type: "string",
              description: "피부 고민사항"
            },
            age_group: {
              type: "string",
              description: "연령대"
            }
          },
          required: ["user_id"]
        }
      }
    ]
  end

  # MCP 프로토콜 핸들러
  post '/' do
    content_type :json
    
    begin
      request_data = JSON.parse(request.body.read)
      method = request_data['method']
      params = request_data['params'] || {}
      id = request_data['id']
      
      case method
      when 'tools/list'
        response = {
          jsonrpc: '2.0',
          id: id,
          result: {
            tools: @tools
          }
        }
      when 'tools/call'
        tool_name = params['name']
        arguments = params['arguments'] || {}
        
        result = call_tool(tool_name, arguments)
        
        response = {
          jsonrpc: '2.0',
          id: id,
          result: {
            content: [
              {
                type: 'text',
                text: JSON.generate(result)
              }
            ]
          }
        }
      else
        response = {
          jsonrpc: '2.0',
          id: id,
          error: {
            code: -32601,
            message: "Method not found: #{method}"
          }
        }
      end
      
      JSON.generate(response)
    rescue => e
      {
        jsonrpc: '2.0',
        id: request_data&.dig('id'),
        error: {
          code: -32603,
          message: "Internal error: #{e.message}"
        }
      }.to_json
    end
  end

  # 서버 정보 엔드포인트
  get '/info' do
    content_type :json
    {
      name: "cosmetic-recommendation-server",
      version: "1.0.0",
      description: "AI 기반 화장품 추천 MCP 서버",
      tools: @tools.map { |tool| tool[:name] }
    }.to_json
  end

  private

  def call_tool(name, arguments)
    case name
    when "register_user_skin_info"
      register_user_skin_info(arguments)
    when "get_cosmetic_recommendations"
      get_cosmetic_recommendations(arguments)
    when "search_products"
      search_products(arguments)
    when "search_ingredients"
      search_ingredients(arguments)
    when "get_products_by_ingredient"
      get_products_by_ingredient(arguments)
    when "get_user_profile"
      get_user_profile(arguments)
    when "update_user_profile"
      update_user_profile(arguments)
    else
      { error: "Unknown tool: #{name}" }
    end
  end

  def register_user_skin_info(args)
    uri = URI("#{@base_url}/users")
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = {
      user: {
        skin_type: args["skin_type"],
        concerns: args["concerns"],
        age_group: args["age_group"]
      }
    }.to_json

    response = http.request(request)
    
    if response.code == "201"
      user_data = JSON.parse(response.body.force_encoding('UTF-8'))
      {
        success: true,
        message: "사용자 피부 정보가 성공적으로 등록되었습니다",
        user: user_data
      }
    else
      {
        success: false,
        error: "사용자 등록 실패: #{response.body.force_encoding('UTF-8')}"
      }
    end
  rescue => e
    { success: false, error: "서버 오류: #{e.message}" }
  end

  def get_cosmetic_recommendations(args)
    user_id = args["user_id"]
    ingredient = args["ingredient"]

    if ingredient && !ingredient.empty?
      # 성분별 추천
      uri = URI("#{@base_url}/recommendations/by_ingredient")
      http = Net::HTTP.new(uri.host, uri.port)
      
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = {
        ingredient: ingredient,
        user_id: user_id
      }.to_json
    else
      # 일반 추천 생성
      uri = URI("#{@base_url}/recommendations/generate")
      http = Net::HTTP.new(uri.host, uri.port)
      
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = { user_id: user_id }.to_json
    end

    response = http.request(request)
    
    if response.code == "200" || response.code == "201"
      recommendations = JSON.parse(response.body.force_encoding('UTF-8'))
      {
        success: true,
        message: "화장품 추천이 생성되었습니다",
        recommendations: recommendations
      }
    else
      {
        success: false,
        error: "추천 생성 실패: #{response.body.force_encoding('UTF-8')}"
      }
    end
  rescue => e
    { success: false, error: "서버 오류: #{e.message}" }
  end

  def search_products(args)
    query = args["query"]
    category = args["category"]
    brand = args["brand"]
    max_price = args["max_price"]
    min_price = args["min_price"]

    uri = URI("#{@base_url}/products/search")
    uri.query = URI.encode_www_form({
      query: query,
      category: category,
      brand: brand,
      max_price: max_price,
      min_price: min_price
    }.compact)

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri)
    
    response = http.request(request)
    
    if response.code == "200"
      products = JSON.parse(response.body.force_encoding('UTF-8'))
      {
        success: true,
        message: "제품 검색이 완료되었습니다",
        products: products,
        count: products.length
      }
    else
      {
        success: false,
        error: "제품 검색 실패: #{response.body.force_encoding('UTF-8')}"
      }
    end
  rescue => e
    { success: false, error: "서버 오류: #{e.message}" }
  end

  def search_ingredients(args)
    query = args["query"]
    effect = args["effect"]
    safety_level = args["safety_level"]

    uri = URI("#{@base_url}/ingredients/search")
    uri.query = URI.encode_www_form({
      query: query,
      effect: effect,
      safety_level: safety_level
    }.compact)

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri)
    
    response = http.request(request)
    
    if response.code == "200"
      ingredients = JSON.parse(response.body.force_encoding('UTF-8'))
      {
        success: true,
        message: "성분 검색이 완료되었습니다",
        ingredients: ingredients,
        count: ingredients.length
      }
    else
      {
        success: false,
        error: "성분 검색 실패: #{response.body.force_encoding('UTF-8')}"
      }
    end
  rescue => e
    { success: false, error: "서버 오류: #{e.message}" }
  end

  def get_products_by_ingredient(args)
    ingredient_name = args["ingredient_name"]
    user_id = args["user_id"]

    uri = URI("#{@base_url}/products/by_ingredient")
    uri.query = URI.encode_www_form({
      ingredient_name: ingredient_name,
      user_id: user_id
    }.compact)

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri)
    
    response = http.request(request)
    
    if response.code == "200"
      products = JSON.parse(response.body.force_encoding('UTF-8'))
      {
        success: true,
        message: "#{ingredient_name} 성분이 포함된 제품들을 찾았습니다",
        products: products,
        count: products.length
      }
    else
      {
        success: false,
        error: "제품 검색 실패: #{response.body.force_encoding('UTF-8')}"
      }
    end
  rescue => e
    { success: false, error: "서버 오류: #{e.message}" }
  end

  def get_user_profile(args)
    user_id = args["user_id"]
    
    uri = URI("#{@base_url}/users/#{user_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri)
    
    response = http.request(request)
    
    if response.code == "200"
      user_data = JSON.parse(response.body.force_encoding('UTF-8'))
      {
        success: true,
        message: "사용자 프로필을 조회했습니다",
        user: user_data
      }
    else
      {
        success: false,
        error: "사용자 조회 실패: #{response.body.force_encoding('UTF-8')}"
      }
    end
  rescue => e
    { success: false, error: "서버 오류: #{e.message}" }
  end

  def update_user_profile(args)
    user_id = args["user_id"]
    skin_type = args["skin_type"]
    concerns = args["concerns"]
    age_group = args["age_group"]
    
    uri = URI("#{@base_url}/users/#{user_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = Net::HTTP::Patch.new(uri)
    request["Content-Type"] = "application/json"
    request.body = {
      user: {
        skin_type: skin_type,
        concerns: concerns,
        age_group: age_group
      }
    }.compact.to_json

    response = http.request(request)
    
    if response.code == "200"
      user_data = JSON.parse(response.body.force_encoding('UTF-8'))
      {
        success: true,
        message: "사용자 프로필이 업데이트되었습니다",
        user: user_data
      }
    else
      {
        success: false,
        error: "사용자 업데이트 실패: #{response.body.force_encoding('UTF-8')}"
      }
    end
  rescue => e
    { success: false, error: "서버 오류: #{e.message}" }
  end
end

# 서버 실행
if __FILE__ == $0
  puts "🎨 내 화장품을 찾아줘! MCP 서버가 시작되었습니다."
  puts "📍 서버 URL: http://localhost:3001"
  puts "🔧 MCP 프로토콜 준수"
  puts "=" * 50
  
  McpServer.run!
end 