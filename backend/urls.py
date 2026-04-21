"""backend URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
# """
# from django.contrib import admin
# from django.urls import path

# urlpatterns = [
#     path('admin/', admin.site.urls),
# ]
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
    return HttpResponse("API is running")
urlpatterns = [
    # path('admin/', admin.site.urls),
    # path('api/', include(router.urls)),
    path('', home),  # 👈 ADD THIS
    path('admin/', admin.site.urls),
    path('api/', include('records.urls')),
]
# Adding JWT authentication URLs
# This allows for token-based authentication in the API.
# urlpatterns += [
#     path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
#     path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
# ]
# This file defines the URL routing for the backend application, including the admin interface and API endpoints for patients and admissions.