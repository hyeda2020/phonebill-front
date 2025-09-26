# 프론트엔드 컨테이너 실행방법 가이드

## 개요
프론트엔드 서비스 'phonebill-front'의 컨테이너 이미지를 VM에서 실행하는 방법을 안내합니다.

## 실행 정보
- **시스템명**: phonebill
- **ACR명**: acrdigitalgarage01
- **VM 정보**:
  - KEY파일: ~/home/bastion-dg0504
  - USERID: azureuser
  - IP: 4.217.168.223
- **서비스명**: phonebill-front (package.json의 "name" 필드값)

## 1. VM 접속 방법

### 1.1 터미널 실행
- **Linux/Mac**: 기본 터미널 실행
- **Windows**: Windows Terminal 실행

### 1.2 VM 접속
최초 한 번 Private key 파일 권한 설정:
```bash
chmod 400 ~/home/bastion-dg0504
```

Private key를 이용하여 VM 접속:
```bash
ssh -i ~/home/bastion-dg0504 azureuser@4.217.168.223
```

## 2. Git Repository 클론

### 2.1 작업 디렉토리 생성
```bash
mkdir -p ~/home/workspace
cd ~/home/workspace
```

### 2.2 소스 클론
```bash
git clone https://github.com/cna-bootcamp/phonebill-front.git
```

### 2.3 프로젝트 디렉토리 이동
```bash
cd phonebill-front
```

## 3. 컨테이너 이미지 생성
`deployment/container/build-image.md` 파일을 열어 가이드대로 컨테이너 이미지를 생성합니다.

## 4. 컨테이너 레지스트리 로그인

### 4.1 ACR 인증정보 확인
```bash
az acr credential show --name acrdigitalgarage01
```

응답 예시:
```json
{
  "passwords": [
    {
      "name": "password",
      "value": "{암호}"
    },
    {
      "name": "password2", 
      "value": "{암호2}"
    }
  ],
  "username": "acrdigitalgarage01"
}
```

### 4.2 Docker 로그인
```bash
docker login acrdigitalgarage01.azurecr.io -u acrdigitalgarage01 -p {암호}
```

## 5. 컨테이너 이미지 푸시

### 5.1 이미지 태깅
```bash
docker tag phonebill-front:latest acrdigitalgarage01.azurecr.io/phonebill/phonebill-front:latest
```

### 5.2 이미지 푸시
```bash
docker push acrdigitalgarage01.azurecr.io/phonebill/phonebill-front:latest
```

## 6. 런타임 환경변수 파일 생성

### 6.1 현재 runtime-env.js 설정 확인
기존 파일 내용:
```javascript
window.__runtime_config__ = {
  // API 서버 설정
  USER_HOST: 'http://localhost:8080',
  BILL_HOST: 'http://localhost:8080', 
  PRODUCT_HOST: 'http://localhost:8080',
  KOS_MOCK_HOST: 'http://localhost:8080',
  API_GROUP: '/api/v1',
  
  // 환경 설정
  NODE_ENV: 'development',
  
  // 기타 설정
  APP_NAME: '통신요금 관리 서비스',
  VERSION: '1.0.0'
};
```

### 6.2 VM용 환경변수 파일 생성
localhost를 VM IP로 변경하여 ~/phonebill-front/public/runtime-env.js 파일을 생성:
```bash
cat > ~/phonebill-front/public/runtime-env.js << 'RUNTIME_EOF'
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
```

## 7. 컨테이너 실행

### 7.1 컨테이너 실행 명령
```bash
SERVER_PORT=3000

docker run -d --name phonebill-front --rm -p ${SERVER_PORT}:8080 \
-v ~/phonebill-front/public/runtime-env.js:/usr/share/nginx/html/runtime-env.js \
acrdigitalgarage01.azurecr.io/phonebill/phonebill-front:latest
```

### 7.2 실행된 컨테이너 확인
```bash
docker ps | grep phonebill-front
```

## 8. 재배포 방법

### 8.1 로컬에서 수정된 소스 푸시
로컬 개발환경에서 코드 수정 후 git push 수행

### 8.2 VM 접속
```bash
ssh -i ~/home/bastion-dg0504 azureuser@4.217.168.223
```

### 8.3 디렉토리 이동 및 소스 업데이트
```bash
cd ~/home/workspace/phonebill-front
git pull
```

### 8.4 컨테이너 이미지 재생성
`deployment/container/build-image.md` 파일 가이드대로 수행

### 8.5 컨테이너 이미지 푸시
```bash
docker tag phonebill-front:latest acrdigitalgarage01.azurecr.io/phonebill/phonebill-front:latest
docker push acrdigitalgarage01.azurecr.io/phonebill/phonebill-front:latest
```

### 8.6 기존 컨테이너 중지
```bash
docker stop phonebill-front
```

### 8.7 컨테이너 이미지 삭제
```bash
docker rmi acrdigitalgarage01.azurecr.io/phonebill/phonebill-front:latest
```

### 8.8 컨테이너 재실행
```bash
SERVER_PORT=3000

docker run -d --name phonebill-front --rm -p ${SERVER_PORT}:8080 \
-v ~/phonebill-front/public/runtime-env.js:/usr/share/nginx/html/runtime-env.js \
acrdigitalgarage01.azurecr.io/phonebill/phonebill-front:latest
```

## 접속 확인
컨테이너 실행 후 웹 브라우저에서 다음 URL로 접속:
- http://4.217.168.223:3000

## 주요 포트
- **Frontend 서비스**: 3000 (외부) → 8080 (내부)
- **API 서버들**: 8080 포트 사용

## 주의사항
- 환경변수 파일의 localhost를 VM IP로 반드시 변경해야 합니다
- 컨테이너 재배포 시 기존 컨테이너를 완전히 정리한 후 재실행합니다
- ACR 로그인 정보는 보안을 위해 적절히 관리해야 합니다
