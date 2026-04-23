# backend/urls.py

from django.contrib import admin
from django.http import HttpResponse
from django.urls import path, include
from rest_framework import routers
from records.views import PatientViewSet, AdmissionViewSet

from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

router = routers.DefaultRouter()
router.register(r'patients', PatientViewSet)
router.register(r'admissions', AdmissionViewSet)


def home(request):
    return HttpResponse("Naya Zehan API is running")


urlpatterns = [
    path('', home, name='home'),
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
    # JWT authentication endpoints
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]