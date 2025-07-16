#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'uri'

class McpClient
  def initialize(server_url = 'http://localhost:3001')
    @server_url = server_url
  end

  def list_tools
    uri = URI(@server_url)
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = {
      jsonrpc: '2.0',
      id: 1,
      method: 'tools/list',
      params: {}
    }.to_json

    response = http.request(request)
    JSON.parse(response.body)
  end

  def call_tool(tool_name, arguments)
    uri = URI(@server_url)
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = {
      jsonrpc: '2.0',
      id: 1,
      method: 'tools/call',
      params: {
        name: tool_name,
        arguments: arguments
      }
    }.to_json

    response = http.request(request)
    JSON.parse(response.body)
  end

  def get_server_info
    uri = URI("#{@server_url}/info")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri)
    
    response = http.request(request)
    JSON.parse(response.body)
  end
end

def print_menu
  puts "\n" + "=" * 50
  puts "🎨 내 화장품을 찾아줘! MCP 클라이언트"
  puts "=" * 50
  puts "1. 서버 정보 조회"
  puts "2. 사용 가능한 도구 목록"
  puts "3. 사용자 등록"
  puts "4. 제품 검색"
  puts "5. 성분 검색"
  puts "6. 화장품 추천"
  puts "7. 사용자 프로필 조회"
  puts "8. 사용자 프로필 업데이트"
  puts "9. 성분별 제품 검색"
  puts "0. 종료"
  puts "=" * 50
end

def get_user_input(prompt)
  print "#{prompt}: "
  gets.chomp
end

def test_user_registration(client)
  puts "\n👤 사용자 등록 테스트"
  puts "-" * 30
  
  skin_type = get_user_input("피부 타입 (dry/oily/combination/sensitive)")
  concerns = get_user_input("고민사항 (쉼표로 구분: acne,aging,brightening,hydration)")
  age_group = get_user_input("연령대 (teens/twenties/thirties/forties_plus)")
  
  result = client.call_tool("register_user_skin_info", {
    "skin_type" => skin_type,
    "concerns" => concerns,
    "age_group" => age_group
  })
  
  puts "\n📋 결과:"
  puts JSON.pretty_generate(result)
end

def test_product_search(client)
  puts "\n🔍 제품 검색 테스트"
  puts "-" * 30
  
  query = get_user_input("검색어")
  category = get_user_input("카테고리 (선택사항)")
  brand = get_user_input("브랜드 (선택사항)")
  max_price = get_user_input("최대 가격 (선택사항)")
  
  arguments = { "query" => query }
  arguments["category"] = category unless category.empty?
  arguments["brand"] = brand unless brand.empty?
  arguments["max_price"] = max_price.to_i unless max_price.empty?
  
  result = client.call_tool("search_products", arguments)
  
  puts "\n📋 결과:"
  puts JSON.pretty_generate(result)
end

def test_ingredient_search(client)
  puts "\n🧪 성분 검색 테스트"
  puts "-" * 30
  
  query = get_user_input("검색어")
  effect = get_user_input("효과 (선택사항)")
  safety_level = get_user_input("안전도 (선택사항)")
  
  arguments = { "query" => query }
  arguments["effect"] = effect unless effect.empty?
  arguments["safety_level"] = safety_level unless safety_level.empty?
  
  result = client.call_tool("search_ingredients", arguments)
  
  puts "\n📋 결과:"
  puts JSON.pretty_generate(result)
end

def test_recommendations(client)
  puts "\n💡 화장품 추천 테스트"
  puts "-" * 30
  
  user_id = get_user_input("사용자 ID")
  ingredient = get_user_input("특정 성분 (선택사항)")
  
  arguments = { "user_id" => user_id.to_i }
  arguments["ingredient"] = ingredient unless ingredient.empty?
  
  result = client.call_tool("get_cosmetic_recommendations", arguments)
  
  puts "\n📋 결과:"
  puts JSON.pretty_generate(result)
end

def test_user_profile(client)
  puts "\n👤 사용자 프로필 조회 테스트"
  puts "-" * 30
  
  user_id = get_user_input("사용자 ID")
  
  result = client.call_tool("get_user_profile", { "user_id" => user_id.to_i })
  
  puts "\n📋 결과:"
  puts JSON.pretty_generate(result)
end

def test_update_profile(client)
  puts "\n✏️ 사용자 프로필 업데이트 테스트"
  puts "-" * 30
  
  user_id = get_user_input("사용자 ID")
  skin_type = get_user_input("피부 타입 (dry/oily/combination/sensitive)")
  concerns = get_user_input("고민사항 (쉼표로 구분)")
  age_group = get_user_input("연령대 (teens/twenties/thirties/forties_plus)")
  
  result = client.call_tool("update_user_profile", {
    "user_id" => user_id.to_i,
    "skin_type" => skin_type,
    "concerns" => concerns,
    "age_group" => age_group
  })
  
  puts "\n📋 결과:"
  puts JSON.pretty_generate(result)
end

def test_products_by_ingredient(client)
  puts "\n🧪 성분별 제품 검색 테스트"
  puts "-" * 30
  
  ingredient_name = get_user_input("성분명")
  user_id = get_user_input("사용자 ID (선택사항)")
  
  arguments = { "ingredient_name" => ingredient_name }
  arguments["user_id"] = user_id.to_i unless user_id.empty?
  
  result = client.call_tool("get_products_by_ingredient", arguments)
  
  puts "\n📋 결과:"
  puts JSON.pretty_generate(result)
end

# 메인 실행
begin
  client = McpClient.new
  
  puts "🎨 내 화장품을 찾아줘! MCP 클라이언트가 시작되었습니다."
  puts "📍 서버 URL: http://localhost:3001"
  puts "💡 MCP 서버가 실행 중인지 확인하세요: ruby bin/mcp_server"
  
  loop do
    print_menu
    choice = get_user_input("선택하세요")
    
    case choice
    when "1"
      puts "\n📋 서버 정보:"
      puts JSON.pretty_generate(client.get_server_info)
    when "2"
      puts "\n🔧 사용 가능한 도구들:"
      result = client.list_tools
      if result["result"] && result["result"]["tools"]
        result["result"]["tools"].each do |tool|
          puts "  • #{tool['name']}: #{tool['description']}"
        end
      else
        puts JSON.pretty_generate(result)
      end
    when "3"
      test_user_registration(client)
    when "4"
      test_product_search(client)
    when "5"
      test_ingredient_search(client)
    when "6"
      test_recommendations(client)
    when "7"
      test_user_profile(client)
    when "8"
      test_update_profile(client)
    when "9"
      test_products_by_ingredient(client)
    when "0"
      puts "\n👋 MCP 클라이언트를 종료합니다."
      break
    else
      puts "\n❌ 잘못된 선택입니다. 다시 시도해주세요."
    end
  end
rescue => e
  puts "\n❌ 오류가 발생했습니다: #{e.message}"
  puts "💡 MCP 서버가 실행 중인지 확인하세요: ruby bin/mcp_server"
end 