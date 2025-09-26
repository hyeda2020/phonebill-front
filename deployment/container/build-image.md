# 프론트엔드 컨테이너 이미지 작성 결과

## 작업 개요
프론트엔드 서비스 'phonebill-front'의 컨테이너 이미지를 생성하였습니다.

## 수행한 작업

### 1. 서비스명 확인
package.json의 "name" 필드에서 서비스명 확인:
```json
{
  "name": "phonebill-front"
}
```

### 2. 의존성 동기화
package.json과 package-lock.json 일치 확인:
```bash
npm install
```

### 3. nginx.conf 파일 생성
위치: `deployment/container/nginx.conf`
- 포트: 8080
- SPA 라우팅 지원 (try_files $uri $uri/ /index.html)
- 정적 파일 캐싱 설정
- Health check 엔드포인트 (/health)

### 4. Dockerfile 생성
위치: `deployment/container/Dockerfile-frontend`
- Multi-stage 빌드 (Node.js 빌드 + nginx 운영)
- Node.js 20-slim 기반 빌드 스테이지
- nginx:stable-alpine 기반 운영 스테이지
- 보안 설정 (nginx 사용자로 실행)

### 5. 컨테이너 이미지 빌드
빌드 명령어:
```bash
DOCKER_FILE=deployment/container/Dockerfile-frontend

docker build \
  --platform linux/amd64 \
  --build-arg PROJECT_FOLDER="." \
  --build-arg BUILD_FOLDER="deployment/container" \
  --build-arg EXPORT_PORT="8080" \
  -f ${DOCKER_FILE} \
  -t phonebill-front:latest .
```

### 6. 이미지 확인
생성된 이미지 확인:
```bash
docker images | grep phonebill-front
```

결과:
```
phonebill-front   latest   b5416f533233   19 seconds ago   76.1MB
```

## 빌드 결과
- ✅ 빌드 성공
- ✅ TypeScript 컴파일 완료
- ✅ Vite 빌드 완료 (dist 폴더 생성)
- ✅ 이미지 크기: 76.1MB
- ✅ 이미지 태그: phonebill-front:latest

## 생성된 파일
1. `deployment/container/nginx.conf` - nginx 설정 파일
2. `deployment/container/Dockerfile-frontend` - Docker 빌드 파일
3. `deployment/container/build-image.md` - 본 결과 문서

## 주요 특징
- Multi-stage 빌드로 최적화된 이미지 크기
- SPA(Single Page Application) 라우팅 지원
- 정적 파일 캐싱 최적화
- Health check 엔드포인트 제공
- 보안 강화 (non-root 사용자 실행)

컨테이너 이미지가 성공적으로 생성되었습니다.
