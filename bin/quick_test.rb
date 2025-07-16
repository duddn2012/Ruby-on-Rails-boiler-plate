#!/usr/bin/env ruby

require_relative '../app/mcp/server'

puts "🎨 MCP 서버 빠른 테스트"
puts "=" * 30

# MCP 서버 인스턴스 생성
mcp_server = McpServer.new

# 테스트 결과를 저장할 배열
test_results = []

# 1. 사용자 등록 테스트
puts "\n1️⃣ 사용자 등록 테스트"
result = mcp_server.call_tool("register_user_skin_info", {
  "skin_type" => "combination",
  "concerns" => "acne,hydration",
  "age_group" => "twenties"
})

if result["success"]
  puts "✅ 사용자 등록 성공"
  user_id = result["user"]["id"]
  test_results << "사용자 등록: 성공 (ID: #{user_id})"
else
  puts "❌ 사용자 등록 실패: #{result["error"]}"
  puts "   디버그 정보: #{result.inspect}"
  test_results << "사용자 등록: 실패"
  user_id = 1 # 기본값 사용
end

# 2. 제품 검색 테스트
puts "\n2️⃣ 제품 검색 테스트"
result = mcp_server.call_tool("search_products", {
  "query" => "moisturizer"
})

if result["success"]
  puts "✅ 제품 검색 성공 (#{result["total_count"]}개 제품)"
  test_results << "제품 검색: 성공"
else
  puts "❌ 제품 검색 실패: #{result["error"]}"
  test_results << "제품 검색: 실패"
end

# 3. 성분 검색 테스트
puts "\n3️⃣ 성분 검색 테스트"
result = mcp_server.call_tool("search_ingredients", {
  "query" => "hyaluronic"
})

if result["success"]
  puts "✅ 성분 검색 성공 (#{result["total_count"]}개 성분)"
  test_results << "성분 검색: 성공"
else
  puts "❌ 성분 검색 실패: #{result["error"]}"
  test_results << "성분 검색: 실패"
end

# 4. 추천 생성 테스트
puts "\n4️⃣ 추천 생성 테스트"
result = mcp_server.call_tool("get_cosmetic_recommendations", {
  "user_id" => user_id
})

if result["success"]
  puts "✅ 추천 생성 성공 (#{result["total_count"]}개 추천)"
  test_results << "추천 생성: 성공"
else
  puts "❌ 추천 생성 실패: #{result["error"]}"
  test_results << "추천 생성: 실패"
end

# 5. 성분별 제품 검색 테스트
puts "\n5️⃣ 성분별 제품 검색 테스트"
result = mcp_server.call_tool("get_products_by_ingredient", {
  "ingredient_name" => "hyaluronic_acid",
  "user_id" => user_id
})

if result["success"]
  puts "✅ 성분별 제품 검색 성공 (#{result["total_count"]}개 제품)"
  test_results << "성분별 제품 검색: 성공"
else
  puts "❌ 성분별 제품 검색 실패: #{result["error"]}"
  test_results << "성분별 제품 검색: 실패"
end

# 6. 사용자 프로필 조회 테스트
puts "\n6️⃣ 사용자 프로필 조회 테스트"
result = mcp_server.call_tool("get_user_profile", {
  "user_id" => user_id
})

if result["success"]
  puts "✅ 프로필 조회 성공"
  test_results << "프로필 조회: 성공"
else
  puts "❌ 프로필 조회 실패: #{result["error"]}"
  test_results << "프로필 조회: 실패"
end

# 결과 요약
puts "\n" + "=" * 30
puts "📊 테스트 결과 요약:"
test_results.each do |result|
  puts "  #{result}"
end

success_count = test_results.count { |r| r.include?("성공") }
total_count = test_results.length

puts "\n🎯 성공률: #{success_count}/#{total_count} (#{(success_count.to_f / total_count * 100).round(1)}%)"

if success_count == total_count
  puts "🎉 모든 테스트가 성공했습니다!"
else
  puts "⚠️  일부 테스트가 실패했습니다. Rails 서버가 실행 중인지 확인해주세요."
end

puts "\n💡 대화형 테스트를 원하시면: ruby bin/test_mcp_interactive.rb" 