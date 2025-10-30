from django.http import HttpResponse

def hello(request):
    return HttpResponse("Hello, World! 👋 From VV-Sembuddy")
