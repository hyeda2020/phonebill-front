#!/bin/bash

# 프론트엔드 컨테이너 배포 스크립트
# phonebill-front 서비스 배포

set -e

# 설정값
SERVICE_NAME="phonebill-front"
SYSTEM_NAME="phonebill"
ACR_NAME="acrdigitalgarage01"
SERVER_PORT="3000"
VM_IP="4.217.168.223"

echo "=== phonebill-front 컨테이너 배포 시작 ==="

# 1. 컨테이너 이미지 태깅
echo "1. 이미지 태깅..."
docker tag ${SERVICE_NAME}:latest ${ACR_NAME}.azurecr.io/${SYSTEM_NAME}/${SERVICE_NAME}:latest

# 2. 컨테이너 이미지 푸시
echo "2. 이미지 푸시..."
docker push ${ACR_NAME}.azurecr.io/${SYSTEM_NAME}/${SERVICE_NAME}:latest

# 3. 기존 컨테이너 중지 (있다면)
echo "3. 기존 컨테이너 중지..."
docker stop ${SERVICE_NAME} 2>/dev/null || echo "기존 컨테이너가 없습니다."

# 4. 환경변수 파일 업데이트
echo "4. 환경변수 파일 생성..."
mkdir -p ~/home/workspace/${SERVICE_NAME}/public
cat > ~/home/workspace/${SERVICE_NAME}/public/runtime-env.js << 'RUNTIME_EOF'
// 런타임 환경 설정
window.__runtime_config__ = {
  // API 서버 설정
  USER_HOST: 'http://4.217.168.223:8080',
  BILL_HOST: 'http://4.217.168.223:8080', 
  PRODUCT_HOST: 'http://4.217.168.223:8080',
  KOS_MOCK_HOST: 'http://4.217.168.223:8080',
  API_GROUP: '/api/v1',
  
  // 환경 설정
  NODE_ENV: 'production',
  
  // 기타 설정
  APP_NAME: '통신요금 관리 서비스',
  VERSION: '1.0.0'
};
RUNTIME_EOF

# 5. 컨테이너 실행
echo "5. 컨테이너 실행..."
docker run -d --name ${SERVICE_NAME} --rm -p ${SERVER_PORT}:8080 \
-v ~/home/workspace/${SERVICE_NAME}/public/runtime-env.js:/usr/share/nginx/html/runtime-env.js \
${ACR_NAME}.azurecr.io/${SYSTEM_NAME}/${SERVICE_NAME}:latest

# 6. 실행 확인
echo "6. 컨테이너 실행 확인..."
sleep 5
docker ps | grep ${SERVICE_NAME}

echo "=== 배포 완료 ==="
echo "접속 URL: http://${VM_IP}:${SERVER_PORT}"
echo "컨테이너 로그 확인: docker logs ${SERVICE_NAME}"
echo "컨테이너 중지: docker stop ${SERVICE_NAME}"
