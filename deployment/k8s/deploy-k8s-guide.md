# Phonebill Frontend 쿠버네티스 배포 가이드

## 배포 정보

- **시스템명**: phonebill
- **서비스명**: phonebill-front
- **ACR명**: acrdigitalgarage01
- **k8s명**: aks-digitalgarage-01
- **네임스페이스**: phonebill-dg0504
- **파드수**: 1
- **리소스(CPU)**: 256m/1024m
- **리소스(메모리)**: 256Mi/1024Mi
- **Gateway Host**: http://phonebill-dg0504-api.20.214.196.128.nip.io

## 배포가이드 검증 결과

### ✅ 체크리스트 검증 완료

1. **객체이름 네이밍룰 준수 여부**
   - ✅ Ingress: phonebill-front
   - ✅ ConfigMap: cm-phonebill-front
   - ✅ Service: phonebill-front
   - ✅ Deployment: phonebill-front

2. **Ingress Controller External IP 확인 및 매니페스트 반영**
   ```bash
   kubectl get svc ingress-nginx-controller -n ingress-nginx
   ```
   - ✅ EXTERNAL-IP: 20.214.196.128
   - ✅ Ingress host: phonebill.20.214.196.128.nip.io

3. **포트 설정 검증**
   - ✅ Ingress 매니페스트의 service port: 8080
   - ✅ Service 매니페스트의 port: 8080
   - ✅ Service 매니페스트의 targetPort: 8080

4. **Image명 확인**
   - ✅ acrdigitalgarage01.azurecr.io/phonebill/phonebill-front:latest

5. **ConfigMap 설정 확인**
   - ✅ ConfigMap 이름: cm-phonebill-front
   - ✅ Key: runtime-env.js
   - ✅ Value: Gateway Host 적용됨 (http://phonebill-dg0504-api.20.214.196.128.nip.io)

## 사전 확인 방법

### 1. Azure 로그인 상태 확인
```bash
az account show
```

### 2. AKS Credential 확인
```bash
kubectl cluster-info
```

### 3. Namespace 존재 확인
```bash
kubectl get ns phonebill-dg0504
```

## 매니페스트 적용 가이드

### 1. 전체 매니페스트 적용
```bash
kubectl apply -f deployment/k8s
```

### 2. 개별 매니페스트 적용 (선택사항)
```bash
# ConfigMap 적용
kubectl apply -f deployment/k8s/configmap.yaml

# Service 적용
kubectl apply -f deployment/k8s/service.yaml

# Deployment 적용
kubectl apply -f deployment/k8s/deployment.yaml

# Ingress 적용
kubectl apply -f deployment/k8s/ingress.yaml
```

## 객체 생성 확인 가이드

### 1. ConfigMap 확인
```bash
kubectl get configmap cm-phonebill-front -n phonebill-dg0504
kubectl describe configmap cm-phonebill-front -n phonebill-dg0504
```

### 2. Service 확인
```bash
kubectl get service phonebill-front -n phonebill-dg0504
kubectl describe service phonebill-front -n phonebill-dg0504
```

### 3. Deployment 확인
```bash
kubectl get deployment phonebill-front -n phonebill-dg0504
kubectl describe deployment phonebill-front -n phonebill-dg0504
```

### 4. Pod 상태 확인
```bash
kubectl get pods -n phonebill-dg0504 -l app=phonebill-front
kubectl logs -n phonebill-dg0504 -l app=phonebill-front
```

### 5. Ingress 확인
```bash
kubectl get ingress phonebill-front -n phonebill-dg0504
kubectl describe ingress phonebill-front -n phonebill-dg0504
```

## 서비스 접속 확인

### 1. 웹 브라우저 접속
```
http://phonebill.20.214.196.128.nip.io
```

### 2. Health Check 확인
```bash
curl http://phonebill.20.214.196.128.nip.io/health
```

## 생성된 매니페스트 파일

- `deployment/k8s/configmap.yaml` - ConfigMap 설정
- `deployment/k8s/service.yaml` - Service 설정
- `deployment/k8s/deployment.yaml` - Deployment 설정
- `deployment/k8s/ingress.yaml` - Ingress 설정

## 주요 설정 내용

### ConfigMap (cm-phonebill-front)
- API 호스트들이 Gateway Host로 설정됨
- 런타임 환경 설정 파일 제공

### Service (phonebill-front)
- ClusterIP 타입으로 내부 통신
- 8080 포트 사용

### Deployment (phonebill-front)
- 1개 Pod 실행
- ACR 이미지 사용
- Health Check 프로브 설정
- 리소스 제한 설정

### Ingress (phonebill-front)
- Nginx 컨트롤러 사용
- 외부 접속 경로 제공