from django.shortcuts import render

# Create your views here.
from django.http import HttpResponse
from django.shortcuts import render, redirect
from .models import Uploads


'''
def file_upload_view(request):
    if request.method == 'POST':
        form = Uploads(request.POST, request.FILES)
        uploaded_file = request.FILES.get('document')  # 'document' should match the name attribute in the form
        if form.is_valid():
            form.save()  # This saves the file to the location specified in the FileField
            return redirect('success_url')  # Redirect after post
    else:
        form = Uploads()
    return render(request, 'upload.html', {'form': form})
'''

def file_upload_view(request):
    print("Method:", request.method)  # Check request method
    if request.method == 'POST':
        print("Files in POST:", request.FILES)  # Check received files
        uploaded_file = request.FILES.get('document')
        print("Uploaded file:", uploaded_file)  # Verify file retrieval
        if uploaded_file:
            instance = Uploads(file=uploaded_file)
            instance.save()
            print("File path:", instance.file.path)  # Check file path
            return HttpResponse("File uploaded successfully!")
    return render(request, 'homepage.html')

def index(request):
    return render(request, 'homepage.html')

