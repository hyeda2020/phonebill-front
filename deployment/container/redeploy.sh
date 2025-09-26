#!/bin/bash

# 프론트엔드 컨테이너 재배포 스크립트
# phonebill-front 서비스 재배포

set -e

# 설정값
SERVICE_NAME="phonebill-front"
SYSTEM_NAME="phonebill"
ACR_NAME="acrdigitalgarage01"
SERVER_PORT="3000"
VM_IP="4.217.168.223"

echo "=== phonebill-front 컨테이너 재배포 시작 ==="

# 1. 기존 컨테이너 중지
echo "1. 기존 컨테이너 중지..."
docker stop ${SERVICE_NAME} 2>/dev/null || echo "실행 중인 컨테이너가 없습니다."

# 2. 기존 이미지 삭제
echo "2. 기존 이미지 삭제..."
docker rmi ${ACR_NAME}.azurecr.io/${SYSTEM_NAME}/${SERVICE_NAME}:latest 2>/dev/null || echo "삭제할 이미지가 없습니다."

# 3. 소스코드 업데이트
echo "3. 소스코드 업데이트..."
git pull

# 4. 새 이미지 빌드 (build-image.md 가이드 자동 실행)
echo "4. 새 컨테이너 이미지 빌드..."
DOCKER_FILE=deployment/container/Dockerfile-frontend

docker build \
  --platform linux/amd64 \
  --build-arg PROJECT_FOLDER="." \
  --build-arg BUILD_FOLDER="deployment/container" \
  --build-arg EXPORT_PORT="8080" \
  -f ${DOCKER_FILE} \
  -t ${SERVICE_NAME}:latest .

# 5. 이미지 태깅
echo "5. 이미지 태깅..."
docker tag ${SERVICE_NAME}:latest ${ACR_NAME}.azurecr.io/${SYSTEM_NAME}/${SERVICE_NAME}:latest

# 6. 이미지 푸시
echo "6. 이미지 푸시..."
docker push ${ACR_NAME}.azurecr.io/${SYSTEM_NAME}/${SERVICE_NAME}:latest

# 7. 환경변수 파일 업데이트
echo "7. 환경변수 파일 업데이트..."
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

# 8. 컨테이너 재실행
echo "8. 컨테이너 재실행..."
docker run -d --name ${SERVICE_NAME} --rm -p ${SERVER_PORT}:8080 \
-v ~/home/workspace/${SERVICE_NAME}/public/runtime-env.js:/usr/share/nginx/html/runtime-env.js \
${ACR_NAME}.azurecr.io/${SYSTEM_NAME}/${SERVICE_NAME}:latest

# 9. 실행 확인
echo "9. 컨테이너 실행 확인..."
sleep 5
docker ps | grep ${SERVICE_NAME}

echo "=== 재배포 완료 ==="
echo "접속 URL: http://${VM_IP}:${SERVER_PORT}"
echo "컨테이너 로그 확인: docker logs ${SERVICE_NAME}"
