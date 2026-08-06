# from django.urls import path
# from . import views
# # backend/urls.py — add import and path
# from records.views import StaffCreateView

# urlpatterns = [
#     path('', home),
#     path('', views.home),  # temporary test route
#     path('admin/', admin.site.urls),
#     path('api/', include(router.urls)),
#     path('api/staff/create/', StaffCreateView.as_view(), name='staff-create'),
#     path('api/token/', RateLimitedTokenObtainPairView.as_view(), name='token_obtain_pair'),
#     path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
# ]
from django.contrib import admin
from django.http import HttpResponse
from django.urls import path, include
from rest_framework import routers
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from django_ratelimit.decorators import ratelimit
from django.utils.decorators import method_decorator

from records.views import PatientViewSet, AdmissionViewSet, StaffCreateView, home


class RateLimitedTokenObtainPairView(TokenObtainPairView):
    @method_decorator(ratelimit(key='ip', rate='5/m', block=True))
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)


router = routers.DefaultRouter()
router.register(r'patients', PatientViewSet)
router.register(r'admissions', AdmissionViewSet)

urlpatterns = [
    path('', home),
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
    path('api/staff/create/', StaffCreateView.as_view(), name='staff-create'),
    path('api/token/', RateLimitedTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]